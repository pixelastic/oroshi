# TRAPUSR1: Refresh prompt on demand {{{
# Whenever we receive USR1, we refresh the prompt display
function TRAPUSR1() {
  # Prompt was generated in the background, we update it
  if [[ $OROSHI_ASYNCHRONOUS_PID != "0" ]]; then
    # Mark the generation as finished
    OROSHI_ASYNCHRONOUS_PID=0

    # Load all prompt parts saved on disk to the global variable
    for promptPart in $OROSHI_ASYNCHRONOUS_PROMPT_PARTS; do
      OROSHI_PROMPT_PARTS[$promptPart]="$(<${OROSHI_ASYNCHRONOUS_SAVE_PATH}/${promptPart})"
    done
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw
  zle && zle reset-prompt
}
# }}}
#
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Dependencies {{{
source $ZSH_CONFIG_PATH/prompt/exit-code.zsh
source $ZSH_CONFIG_PATH/prompt/git.zsh
source $ZSH_CONFIG_PATH/prompt/node.zsh
source $ZSH_CONFIG_PATH/prompt/yarn.zsh
source $ZSH_CONFIG_PATH/prompt/path.zsh
source $ZSH_CONFIG_PATH/prompt/ruby.zsh
# }}}

# Overview {{{
# The best prompt is one that is blazingly fast, and also displays
# all the relevant information. But, as the computation to get this information
# can be slow, tricks have to be deployed to keep the display fast.
#
# Both right and left prompt are designed to be fast to display on their first
# invocation. They only display relevant information that is quick to access
# (ie. no heavy git or node calls).
#
# More expensive information is fetched in the background, and the prompts are
# updated once the information is obtained. Subsequent displays then recomputes
# data that need to stay fresh (like filepaths and exit codes), and freezes old
# data in place (like branch name or git status) while fetching fresh data in
# the background and displaying it once obtained.
# }}}

# Variables {{{
# Those variable holds the various states of the prompt. Because the display of
# the prompt happens in several phases, those variables help us hold a shared
# state.

# Those two arrays define all the prompt path that will be fetched (calling
# related oroshi-prompt-***-populate methods). Depending on the array, they will
# be fetched synchronously or asynchronously.
OROSHI_SYNCHRONOUS_PROMPT_PARTS=(
  path
  git_status
  git_is_submodule
  exit_code
)
# TODO: Benchmark this to see the slowest and improve them
# TODO: Check vcs_info to see if it makes things easier/faster:
# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
OROSHI_ASYNCHRONOUS_PROMPT_PARTS=(
  git_has_stash
  git_rebase_in_progress
  git_rebase_status
  git_branch
  git_tag
  git_remote
  git_issues
  git_pullrequests
  node_monorepo
  yarn_link
  yarn_install_in_progress
  node_version
  ruby_version
)

# This variables holds the pid of the function currently generating all the
# information in the background. We need it to make sure we're only running one
# such method at a time
OROSHI_ASYNCHRONOUS_PID=0

# Folder to store the asynchronously generated prompt parts
OROSHI_ASYNCHRONOUS_SAVE_PATH=${OROSHI_TMP_FOLDER}/prompt-parts
mkdir -p $OROSHI_ASYNCHRONOUS_SAVE_PATH

# This is the global variable that holds all the prompt parts for display
declare -Ag OROSHI_PROMPT_PARTS
OROSHI_PROMPT_PARTS=()

# We store the exit code of the last command played as we'll use it to change
# the color of our prompt
OROSHI_LAST_COMMAND_EXIT="0"

# }}}

# Prompts {{{
# Those methods are called by PROMPT and RPROMPT and display the left and right
# prompts.

# Left prompt
function oroshi-prompt-left() {
  local promptLeft=(
    $OROSHI_PROMPT_PARTS[path]
    $OROSHI_PROMPT_PARTS[node_monorepo]
    $OROSHI_PROMPT_PARTS[yarn_link]
    $OROSHI_PROMPT_PARTS[yarn_install_in_progress]
    $OROSHI_PROMPT_PARTS[bundle_install_in_progress]
    $OROSHI_PROMPT_PARTS[git_is_submodule]
    $OROSHI_PROMPT_PARTS[git_has_stash]
    $OROSHI_PROMPT_PARTS[git_rebase_in_progress]
    $OROSHI_PROMPT_PARTS[git_status]
    $OROSHI_PROMPT_PARTS[exit_code]
  )
  echo $promptLeft
}
PROMPT='$(oroshi-prompt-left)'

function oroshi-prompt-right() {
  local promptRight=(
    $OROSHI_PROMPT_PARTS[git_rebase_status]
    $OROSHI_PROMPT_PARTS[ruby_version]
    $OROSHI_PROMPT_PARTS[node_version]
    $OROSHI_PROMPT_PARTS[git_issues]
    $OROSHI_PROMPT_PARTS[git_pullrequests]
    $OROSHI_PROMPT_PARTS[git_tag]
    $OROSHI_PROMPT_PARTS[git_remote]
    $OROSHI_PROMPT_PARTS[git_branch]
  )
  echo -n $promptRight
}
RPROMPT='$(oroshi-prompt-right)'

# }}}

# precmd {{{
# Those methods are called right after each command, just before the prompt is
# displayed. We use them to set some global variables used by the prompt
autoload -Uz add-zsh-hook

# Keep a reference to the last command exit code as it will probably be
# overwritten by our other functions
function oroshi-last-command-exit-store() {
  OROSHI_LAST_COMMAND_EXIT="$?"
}
add-zsh-hook precmd oroshi-last-command-exit-store

# Keep a reference to commonly used $GIT_ variables, so we don't compute them
# too often
function oroshi-git-env-store() {
  GIT_DIRECTORY_IS_REPOSITORY="$(git-directory-is-repository && echo 1 || echo 0)"
}
add-zsh-hook precmd oroshi-git-env-store

# Synchronously populate prompt parts that are quick to generate
function oroshi-prompt-synchronous-populate() {
  for promptPart in $OROSHI_SYNCHRONOUS_PROMPT_PARTS; do
    eval "oroshi-prompt-populate:${promptPart}"
  done
}
add-zsh-hook precmd oroshi-prompt-synchronous-populate

# Asynchronously populate prompt parts that are slow to generate
function oroshi-prompt-asynchronous-populate() {
  # Don't start another background generation if one is already occuring
  if [[ "${OROSHI_ASYNCHRONOUS_PID}" != "0" ]]; then
    return
  fi
  # # Kill the previous prompt generation process if it was already running
  # # This allows keeping only one generation at a time
  # if [[ "${OROSHI_ASYNCHRONOUS_PID}" != "0" ]]; then
  #   kill -s HUP $OROSHI_ASYNCHRONOUS_PID >/dev/null 2>&1 || :
  # fi

  function async() {
    # Save all new parts in a file
    for promptPart in $OROSHI_ASYNCHRONOUS_PROMPT_PARTS; do
      eval "oroshi-prompt-populate:${promptPart}"
      echo $OROSHI_PROMPT_PARTS[$promptPart] >! ${OROSHI_ASYNCHRONOUS_SAVE_PATH}/${promptPart}
    done

    prompt-refresh $OROSHI_ZSH_PID
  }

  async &!
  OROSHI_ASYNCHRONOUS_PID=$!
}
add-zsh-hook precmd oroshi-prompt-asynchronous-populate
# }}}

# Cursors {{{
function _cursor-cmd() { print -n "\e]12;${COLOR_EMERALD_HEXA}\a" }
function _cursor-ins() { print -n "\e]12;${COLOR_AMBER_HEXA}\a" }
# }}}

