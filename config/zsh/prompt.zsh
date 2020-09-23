local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

which nvm &>/dev/null && hasNvm=1

PROMPT='$(oroshi_prompt_path) $(oroshi_prompt_node_flags)$(oroshi_prompt_git_flags)$(oroshi_prompt_character)'
RPROMPT=''
function get_RPROMPT() {
  echo -n "$(oroshi_prompt_ruby)"
  echo -n "$(oroshi_prompt_node)"
  echo -n "$(oroshi_prompt_git_right)"
}

# Asynchronous right prompt {{{
# Clever idea taken from:
# http://www.anishathalye.com/2015/02/07/an-asynchronous-shell-prompt/

# PID of the forked process
PROMPT_ASYNC_PID=0

# Builtin command called when receiving a USR1 signal
function TRAPUSR1() {
  # Setting the prompt
  RPROMPT="$(\cat /tmp/zsh_rprompt)"
  # Redraw
  zle && zle reset-prompt
  # Reset PID
  PROMPT_ASYNC_PID=0
}

# Builtin command executed before the prompt is displayed
# This will end quickly, but fork a sub process
function precmd() {
  OROSHI_LAST_COMMAND_EXIT="$?"

  # Always kill previous async subprocess if still running
  if [[ "${PROMPT_ASYNC_PID}" != 0 ]]; then
    kill -s HUP $PROMPT_ASYNC_PID >/dev/null 2>&1 || :
  fi

  # Write RPROMPT to a tmp file
  # Signal parent process that we're done (will trigger TRAPUSR1)
  function async() {
    echo "$(get_RPROMPT)" >! "/tmp/zsh_rprompt"
    kill -s USR1 $$
  }

  # Fork subprocess, but keep a reference to its PID
  async &!
  PROMPT_ASYNC_PID=$!
}
# }}}

# LEFT
# Path {{{
# This will return a formatted path.
# - If more than 4 directories, will only keep the first and the last two
# - Will prepend a ! and display it in red if not writable
function oroshi_prompt_path() {
  local promptPath="$(print -D $PWD)"
  promptPath=${promptPath:s/~/ }
  local splitPath
  splitPath=(${(s:/:)promptPath})

  # Keep only first and last dirs if too long
  if [[ ${#splitPath[*]} -ge 4 ]]; then
    promptPath="/${splitPath[1]}/…${splitPath[-2]}/${splitPath[-1]}/"
    promptPath=${promptPath:s/\//}
  fi

  # Write in red for unwritable paths
  local color=$COLOR[green]
  [[ ! -w $PWD ]] && $color=$COLOR[red]

  echo "%F{$color}${promptPath}%f"
}
# }}}
# Git  {{{
# Will display informations about the current git repository (if any):
# - If in a submodule
# - If has changes stashes
# - If the repo is dirty
function oroshi_prompt_git_flags() {
  git-is-repository || return

  git-is-submodule && echo -n "%F{$COLOR[yellow]} %f"
  git stash show &>/dev/null && echo -n "%F{$COLOR[pink8]} %f"
  git-rebase-inprogress && echo -n "%F{$COLOR[red6]} %f"

  echo "$(oroshi_prompt_git_dirty)"
}
# }}}
# Git: Dirty {{{
function oroshi_prompt_git_dirty() {
  # Staged files
  if git-directory-has-staged-files; then
    echo "%F{$COLOR[purple]}ﰖ%f"
    return
  fi

  # Modified, deleted or newly added files
  if git-directory-is-dirty; then
    echo "%F{$COLOR[red]}ﰖ%f"
    return
  fi

  echo "%F{$COLOR[green]}ﰖ%f"
}
# }}}
# Node {{{
# - If has linked modules
function oroshi_prompt_node_flags() {
  yarn-has-links && echo -n "%F{$COLOR[blue7]} %f"
}
# }}}
# Prompt char {{{
function oroshi_prompt_character() {
  if [[ $OROSHI_LAST_COMMAND_EXIT = 1 ]]; then
    echo "%B%F{$COLOR[red]} ❯ %f%b"
    return;
  fi
  if [[ $OROSHI_LAST_COMMAND_EXIT > 1 ]] ; then
    echo "%F{$COLOR[yellow]} ❯ %f"
    return
  fi
  echo "%F{$COLOR[green]} ❯ %f"
}
# }}}

# RIGHT:
# Ruby {{{
function oroshi_prompt_ruby() {
  # TODO: Rewrite with rbenv instead of RVM
  # # No rvm
  # if ! which rvm &>/dev/null; then
  #   return
  # fi
  # defaultVersion="$(ruby-version-default)"
  # currentVersion="$(rvm-prompt v)"
  # # Default version
  # if [[ $defaultVersion == $currentVersion ]]; then
  #   return
  # fi
  # echo "$FG[pink]  $currentVersion %f"
}
# }}}
# Python {{{
# Note: Currently unused
function oroshi_prompt_python() {
  # # In a global pyenv environment
  # [[ ! $PYENV_VERSION == "" ]] && display=" $PYENV_VERSION "
  # # In a local pipenv shell (the [] help remember to press Ctrl-D to get out)
  # [[ $PIPENV_ACTIVE == "1" ]] && display="[ $(python-version)] "

  # if [[ $display == '' ]]; then
  #   return
  # fi
  # echo "$FG[green9]${display}%f"
}
# }}}
# Node {{{
function oroshi_prompt_node() {
  # No nvm
  [ ! -v hasNvm ] && return

  currentVersion="$(nvm-version-current)"
  expectedVersion="$(cat `nvm_find_nvmrc`)"

  # Stop if project has no version specified
  [[ $expectedVersion = '' ]] && return

  # Not using the project specific version
  if [[ $currentVersion != $expectedVersion ]]; then
    echo "%F{$COLOR[red]} $currentVersion%f"
    return
  fi
}
# }}}
# }}}
# Git (right) {{{
function oroshi_prompt_git_right() {
  git-is-repository || return

  # Replace all with rebase information
  if git-rebase-inprogress; then
    echo "$(oroshi_prompt_git_rebase)"
    return
  fi

  echo -n "$(oroshi_prompt_git_tag)"
  echo -n "$(oroshi_prompt_git_remote)"
  echo -n "$(oroshi_prompt_git_branch)"
}
# }}}
# Git: Rebase {{{
function oroshi_prompt_git_rebase() {
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo -n "%B%F{$COLOR[red6]} ${currentStep}/${maxStep} %f%b"

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(oroshi_prompt_git_branch_color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(oroshi_prompt_git_branch_color $transplantBranch)"


  echo -n "%F{$COLOR[gray]}[trunk]%f"
  echo -n "%F{$COLOR[$ontoColor]}[${ontoBranch}]%f"
  echo -n "%F{$COLOR[$transplantColor]}[${transplantBranch}]%f"
}
# }}}
# Git: Tag {{{
function oroshi_prompt_git_tag() {
  local tagName="$(git tag-current)"
  [[ $tagName = '' ]] && return

  # Check if commits have been added since last tag
  git-commit-tagged && echo -n " %F{$COLOR[orange]} $tagName" && return
  echo -n " %F{$COLOR[gray7]}炙$tagName"
}
# }}}
# Git: Remote {{{
function oroshi_prompt_git_remote() {
  local remoteName="$(git remote-current)"
  [[ $remoteName = 'origin' || $remoteName == '' ]] && return;

  echo " %F{$COLOR[yellow]} $remoteName%f"
}
# }}}
# Git: Branch {{{
function oroshi_prompt_git_branch() {
  local branchName="$(git branch-current)"
  [[ $branchName = '' ]] && return;

  # Detached
  if [[ $branchName = 'HEAD' ]]; then
    branchName=" $(git commit-current)"
    echo " %F{$COLOR[red]}${branchName}%f"
    return
  fi

  # Upstream is gone
  git-branch-gone && echo " %F{$COLOR[red]} ${branchName}%f" && return


  local branchColor="$(oroshi_prompt_git_branch_color $branchName)"

  local remoteStatus
  remoteStatus="$(git-branch-remote-status)"
  [[ $remoteStatus = 'local_ahead' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_behind' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_diverged' ]] && echo -n " %F{$COLOR[red]} $branchName%f"
  [[ $remoteStatus = 'local_never_pushed' ]] && echo -n " %F{$COLOR[$branchColor]} $branchName%f"
  [[ $remoteStatus = 'local_identical' ]] && echo -n " %F{$COLOR[$branchColor]}$branchName%f"
}
# Get the name of the color based on the name of the branch
function oroshi_prompt_git_branch_color() {
  [[ $1 == "master" ]] && echo "blue5" && return;
  [[ $1 == "main" ]] && echo "blue" && return;
  [[ $1 == "develop" ]] && echo "yellow" && return;
  [[ $1 == "heroku" ]] && echo "purple" && return;
  echo "orange"
}
# }}}

# chpwd() {{{
function chpwd() {
  # Set current path as the window title
  print -Pn "\e]2;%~/\a"
}
# }}}

# # Highlighting as I type {{{
# source ~/.oroshi/config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
# ZSH_HIGHLIGHT_STYLES[default]="fg=$promptColor[commandText]"
# ZSH_HIGHLIGHT_STYLES[builtin]="fg=$promptColor[commandCommand]"
# ZSH_HIGHLIGHT_STYLES[command]="fg=$promptColor[commandCommand]"
# ZSH_HIGHLIGHT_STYLES[alias]="fg=$promptColor[commandAlias]"
# ZSH_HIGHLIGHT_STYLES[function]="fg=$promptColor[commandAlias]"
# ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$promptColor[commandError]"
# ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$promptColor[commandKeyword]"
# ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$promptColor[commandArgument]"
# ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$promptColor[commandArgument]"
# ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$promptColor[commandString]"
# ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$promptColor[commandString]"
# ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$promptColor[commandString]"
# ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$promptColor[commandSeparator]"
# ZSH_HIGHLIGHT_STYLES[path]="fg=$promptColor[commandPath]"
# ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=$promptColor[commandPathIncomplete]"
# ZSH_HIGHLIGHT_STYLES[precommand]=none
# ZSH_HIGHLIGHT_STYLES[hashed-command]=none
# ZSH_HIGHLIGHT_STYLES[path_approx]=none
# ZSH_HIGHLIGHT_STYLES[globbing]=none
# ZSH_HIGHLIGHT_STYLES[history-expansion]=none
# ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=none
# ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=none
# ZSH_HIGHLIGHT_STYLES[assign]=none
# # }}}

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
