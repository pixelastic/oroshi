local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))
# init
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

PROMPT='$(oroshi_prompt_path)$(oroshi_prompt_node_links)$(oroshi_prompt_git_left)$(oroshi_prompt_character)'
RPROMPT=''
function get_RPROMPT() {
  echo "$(oroshi_prompt_git_right)"
  # echo "$(oroshi_prompt_ruby)$(oroshi_prompt_python)$(oroshi_prompt_node)$(oroshi_prompt_git_right)"
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
  local color=$FG[green]
  [[ ! -w $PWD ]] && $color="$BOLD$FG[red]"

  echo "$FG[green]${promptPath}$RESET"
}
# }}}
# Git (left) {{{
# Will display informations about the current git repository (if any):
# - If in a submodule
# - If has changes stashes
# - If in a rebase
# - If the repo is dirty
function oroshi_prompt_git_left() {
  if ! git-is-repository; then
    return
  fi
  echo " $(oroshi_prompt_git_submodule)$(oroshi_prompt_git_stash)$(oroshi_prompt_git_rebase_left)$(oroshi_prompt_git_dirty)"
}
# }}}
# Git: Submodule {{{
function oroshi_prompt_git_submodule() {
  if git is-submodule; then
    echo "$FG[yellow]  $RESET"
  fi
}
# }}}
# Git: Stash {{{
function oroshi_prompt_git_stash() {
  if git stash show &>/dev/null; then
    echo "$FG[teal]  $RESET"
  fi
}
# }}}
# Git: Rebase {{{
function oroshi_prompt_git_rebase_left() {
  if ! git-rebase-inprogress; then
    return
  fi
  local currentStep="$(git-rebase-step-current)"
  local maxStep="$(git-rebase-step-max)"

  echo "$FG[teal]  ${currentStep}/${maxStep} $RESET"
}
# }}}
# Git: Dirty {{{
function oroshi_prompt_git_dirty() {
  # Staged files
  if git-directory-has-staged-files; then
    echo "$FG[purple]±$RESET"
    return
  fi

  # Modified, deleted or newly added files
  if git-directory-is-dirty; then
    echo "$FG[red]±$RESET"
    return
  fi

  echo "$FG[green]±$RESET"
}
# }}}
# Prompt char {{{
function oroshi_prompt_character() {
  if [[ $OROSHI_LAST_COMMAND_EXIT = 1 ]]; then
    echo "$BOLD$FG[red] ❯ $RESET"
    return;
  fi
  if [[ $OROSHI_LAST_COMMAND_EXIT > 1 ]] ; then
    echo "$FG[yellow] ❯ $RESET"
    return
  fi
  echo "$FG[green] ❯ $RESET"
}
# }}}

# RIGHT:
# Ruby {{{
function oroshi_prompt_ruby() {
  # No rvm
  if ! which rvm &>/dev/null; then
    return
  fi
  defaultVersion="$(ruby-version-default)"
  currentVersion="$(rvm-prompt v)"
  # Default version
  if [[ $defaultVersion == $currentVersion ]]; then
    return
  fi
  echo "$FG[pink]  $currentVersion $RESET"
}
# }}}
# Python {{{
function oroshi_prompt_python() {
  # In a global pyenv environment
  [[ ! $PYENV_VERSION == "" ]] && display=" $PYENV_VERSION "
  # In a local pipenv shell (the [] help remember to press Ctrl-D to get out)
  [[ $PIPENV_ACTIVE == "1" ]] && display="[ $(python-version)] "

  if [[ $display == '' ]]; then
    return
  fi
  echo "$FG[green9]${display}$RESET"
}
# }}}
# Node {{{
# - Nothing displayed if using the default node version
# - Version in green with ⬢ if using a custom version
# - Version in red with ⬢ if should use a specific version but is not
function oroshi_prompt_node() {
  # No nvm
  if ! which nvm &>/dev/null; then
    return
  fi

  currentVersion="$(nvm-version-current)"
  defaultVersion="$(nvm version default | sed 's/v//')"

  # This dir has a specific version defined, but we're not following it
  expectedVersion="$(cat `nvm_find_nvmrc`)"
  if version-compare "$currentVersion < $expectedVersion"; then
    echo "$FG[red] $currentVersion ($expectedVersion) $RESET"
    return
  fi

  # We are using the default version, nothing to display
  if [[ $currentVersion == $defaultVersion ]]; then
    return
  fi

  # Current version not the default one
  echo "$FG[yellow] $currentVersion $RESET"
}
# }}}
# Node (linked modules) {{{
function oroshi_prompt_node_links() {
  # No nvm
  if ! yarn-has-links; then
    return
  fi
  echo "$FG[blue]  $RESET"
}
# }}}
# }}}
# Git (right) {{{
function oroshi_prompt_git_right() {
  if ! git-is-repository; then
    return
  fi

  # # Is actually in the middle of a rebase
  # if git-rebase-inprogress; then
  #   echo "$(oroshi_prompt_git_rebase_right)"
  #   return
  # fi

  tag=`oroshi_prompt_git_tag`
  echo $tag
  # remote=`oroshi_prompt_git_remote`
  # branch=`oroshi_prompt_git_branch`
  # echo "${tag}${remote}${branch}"
}
# }}}
# Git: Rebase {{{
function oroshi_prompt_git_rebase_right() {
  # No rebase in progress
  if ! git-rebase-inprogress; then
    return
  fi

  local ontoBranch="$(git-rebase-onto)"
  local ontoColor="$(oroshi_prompt_git_branch_color $ontoBranch)"
  local transplantBranch="$(git-rebase-transplant)"
  local transplantColor="$(oroshi_prompt_git_branch_color $transplantBranch)"


  echo -n "$FG[grey] [trunk]$RESET"
  echo -n "$FG[orange] [${ontoBranch}]$RESET"
  echo -n "$FG[green][${transplantBranch}]$RESET"
}
# }}}
# Git: Tag {{{
function oroshi_prompt_git_tag() {
  local tagName="$(git tag-current)"
  if [[ $tagName = '' ]]; then
    return
  fi

  # Check if commits have been added since last tag
  local tagColor='tagOutdated'
  if git commit-tagged; then
    tagColor='tagCurrent'
    tagName="$tagName "
  else
    tagName=" $tagName "
  fi

  echo -n "$FG[gray]$tagName$RESET"
}
# }}}
# Git: Remote {{{
function oroshi_prompt_git_remote() {
  local remoteName="$(git remote-current)"
  local remoteColor='remoteDefault'

  # Default remote
  if [[ $remoteName = 'origin' || $remoteName == '' ]]; then
    return;
  fi

  local color="blue";
  [[ $remoteName == 'github' ]] && color=$FG[blue2]
  [[ $remoteName == 'heroku' ]] && color=$FG[heroku]
  [[ $remoteName == 'pixelastic' ]] && color=$FG[green3]
  [[ $remoteName == 'upstream' ]] && color=$FG[orange]

  echo "${color} $remoteName$RESET"
}
# }}}
# Git: Branch {{{
function oroshi_prompt_git_branch() {
  local branchName="$(git branch-current)"

  # Not in a branch
  if [[ $branchName = '' ]]; then
    return;
  fi

  # In detached head, we stop now
  if git-branch-gone; then
    echo "$FG[red] ${branchName}$RESET"
    return
  fi
  
  # Upstream is gone
  if [[ $branchName = 'HEAD' ]]; then
    branchName="$(git commit-current)  "
    echo "$FG[red9]${branchName}$RESET"
    return
  fi

  local branchColor=oroshi_prompt_git_branch_color($branchName)

  # Adding push/pull indicator
  local pushPullSymbol="$(oroshi_prompt_git_push_pull)"
  if [[ $pushPullSymbol != '' ]]; then
    branchName="${pushPullSymbol} ${branchName}"
  fi

  echo "$FG[$branchColor]$branchName$RESET"
}
# Get the name of the color based on the name of the branch
function oroshi_prompt_git_branch_color() {
  [[ $1 == "master" ]] && return "blue";
  [[ $1 == "main" ]] && return "blue";
  [[ $1 == "develop" ]] && return "yellow";
  [[ $1 == "heroku" ]] && return "purple";
  return "orange"
}
# }}}
# Git: Push/Pull {{{
function oroshi_prompt_git_push_pull() {
  local EXIT_CODE_IDENTICAL=0
  local EXIT_CODE_AHEAD=1
  local EXIT_CODE_BEHIND=2
  local EXIT_CODE_DIVERGED=3
  local EXIT_CODE_NEVER_PUSHED=4
  local remoteStatus
  remoteStatus="$(git-branch-remote-status)$?"

  case "$remoteStatus" in
    $EXIT_CODE_AHEAD)
      echo " "
      ;;
    $EXIT_CODE_BEHIND)
      echo " "
      ;;
    $EXIT_CODE_DIVERGED)
      echo " "
      ;;
    $EXIT_CODE_NEVER_PUSHED)
      echo " "
      ;;
  esac
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
