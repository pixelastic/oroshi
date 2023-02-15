setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Dependencies {{{
require 'prompt/exit-code'
require 'prompt/git'
require 'prompt/node'
require 'prompt/yarn'
require 'prompt/path'
require 'prompt/ruby'
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
  exit-code
  git-status
  path
)
# TODO: Benchmark this to see the slowest and improve them
OROSHI_ASYNCHRONOUS_PROMPT_PARTS=(
  git-is-submodule
  git-has-stash
  git-rebase-in-progress
  git-rebase-status
  git-branch
  git-tag
  git-remote
  git-issues
  git-pullrequests
  node-monorepo
  yarn-link
  yarn-install-in-progress
  node-version
  ruby-version
)

# This variables holds the pid of the function currently generating all the
# information in the background. We need it to make sure we're only running one
# such method at a time
OROSHI_ASYNCHRONOUS_PID=0

# Folder to store the asynchronously generated prompt parts
OROSHI_ASYNCHRONOUS_SAVE_PATH=/tmp/oroshi/prompt-parts
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
    $OROSHI_PROMPT_PARTS[node-monorepo]
    $OROSHI_PROMPT_PARTS[yarn-link]
    $OROSHI_PROMPT_PARTS[yarn-install-in-progress]
    $OROSHI_PROMPT_PARTS[bundle-install-in-progress]
    $OROSHI_PROMPT_PARTS[git-is-submodule]
    $OROSHI_PROMPT_PARTS[git-has-stash]
    $OROSHI_PROMPT_PARTS[git-rebase-in-progress]
    $OROSHI_PROMPT_PARTS[git-status]
    $OROSHI_PROMPT_PARTS[exit-code]
  )
  echo $promptLeft
}
PROMPT='$(oroshi-prompt-left)'

function oroshi-prompt-right() {
  local promptRight=(
    $OROSHI_PROMPT_PARTS[ruby-version]
    $OROSHI_PROMPT_PARTS[node-version]
    $OROSHI_PROMPT_PARTS[git-rebase-status]
    $OROSHI_PROMPT_PARTS[git-issues]
    $OROSHI_PROMPT_PARTS[git-pullrequests]
    $OROSHI_PROMPT_PARTS[git-tag]
    $OROSHI_PROMPT_PARTS[git-remote]
    $OROSHI_PROMPT_PARTS[git-branch]
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

# Update the $GIT_ env variables that are used by the prompt
add-zsh-hook precmd git-env-update

# Synchronously populate prompt parts that are quick to generate
function oroshi-prompt-synchronous-populate() {
  for promptPart in $OROSHI_SYNCHRONOUS_PROMPT_PARTS; do
    eval "oroshi-prompt-${promptPart}-populate"
  done
}
add-zsh-hook precmd oroshi-prompt-synchronous-populate

# Asynchronously populate prompt parts that are slow to generate
function oroshi-prompt-asynchronous-populate() {
  # Kill the previous prompt generation process if it was already running
  # This allows keeping only one generation at a time
  if [[ "${OROSHI_ASYNCHRONOUS_PID}" != "0" ]]; then
    kill -s HUP $OROSHI_ASYNCHRONOUS_PID >/dev/null 2>&1 || :
  fi

  function async() {
    # Save all new parts in a file
    for promptPart in $OROSHI_ASYNCHRONOUS_PROMPT_PARTS; do
      eval "oroshi-prompt-${promptPart}-populate"
      echo $OROSHI_PROMPT_PARTS[$promptPart] >! ${OROSHI_ASYNCHRONOUS_SAVE_PATH}/${promptPart}
    done

    # prompt-refresh
  }

  async &!
  OROSHI_ASYNCHRONOUS_PID=$!
}
add-zsh-hook precmd oroshi-prompt-asynchronous-populate


# TRAPUSR1: Refresh prompt on demand {{{
# Whenever we receive USR1, we refresh the prompt display
function TRAPUSR1() {
  return

  # Prompt was generated in the background, we update it
  if [[ $OROSHI_ASYNCHRONOUS_PID != "0" ]]; then
    # Load all prompt parts saved on disk to the global variable
    for promptPart in $OROSHI_ASYNCHRONOUS_PROMPT_PARTS; do
      OROSHI_PROMPT_PARTS[$promptPart]="$(<${OROSHI_ASYNCHRONOUS_SAVE_PATH}/${promptPart})"
    done

    # Mark the generation as finished
    OROSHI_ASYNCHRONOUS_PID=0
  fi

  # We add a protection, to prevent the refreshing of the prompt, for example
  # if fzf is currently running, as it will mess the display up
  [[ $PROMPT_PREVENT_REFRESH == "1" ]] && return

  # Redraw
  zle && zle reset-prompt
}
# }}}
