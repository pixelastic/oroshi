# Fancy prompt.

# init
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

PROMPT='${promptUsername}$(getPromptExitCode)${promptHostname}:$(getPromptPath) $(getPromptHash) '
RPROMPT=''
function get_RPROMPT() {
  echo "$(getPromptRepoIndicator)$(getConnectionIndicator)"
}

# Asynchronous right prompt {{{
# Clever idea taken from:
# http://www.anishathalye.com/2015/02/07/an-asynchronous-shell-prompt/

# PID of the forked process
PROMPT_ASYNC_PID=0

# Builtin command executed before the prompt is displayed
# This will end quickly, but fork a sub process
function precmd() {
    # Always kill previous async subprocess if still running
    if [[ "${PROMPT_SYNC_PID}" != 0 ]]; then
        kill -s HUP $PROMPT_SYNC_PID >/dev/null 2>&1 || :
    fi

    # Write RPROMPT to a tmp file
    # Signal parent process that we're done (will trigger TRAPUSR1)
    function async() {
      echo "$(get_RPROMPT)" > "/tmp/zsh_rprompt"
      kill -s USR1 $$
    }

    # Fork subprocess, but keep a reference to its PID
    async &!
    PROMPT_ASYNC_PID=$!
}

# Builtin command called when receiving a USR1 signal
function TRAPUSR1() {
    # Setting the prompt
    RPROMPT="$(cat /tmp/zsh_rprompt)"
    # Redraw
    zle && zle reset-prompt
    # Reset PID
    PROMPT_ASYNC_PID=0
}
# }}}

# Colorize {{{
function colorize() {
  echo "$FG[$promptColor[$2]]$1$FX[reset]"
}
# }}}

# User {{{
promptUsername=$(colorize '%n' 'username')
# }}}

# Exit code {{{
function getPromptExitCode() {
  # Color the @ if last command was an error
  if [[ $? > 0 ]]; then
    echo $(colorize '@'  'lastCommandFailed')
  else
    echo "@"
  fi
}
# }}}

# Hostname {{{
promptHostname=$(colorize '%m' 'hostname')
# }}}

# Path {{{
# This will return a formatted path.
# - If more than 4 directories, will only keep the first and the last two
# - Will prepend a ! and display it in red if not writable
function getPromptPath() {
  local promptPath=$PWD
  local splitPath
  splitPath=(${(s:/:)PWD})

  # Keep only first and last dirs if too long
  if [[ ${#splitPath[*]} -ge 4 ]]; then
    promptPath=/${splitPath[1]}/../${splitPath[-2]}/${splitPath[-1]}/
  fi

  if [[ $promptPath = $HOME ]]; then
    promptPath=' '
  fi

  local pathColor='pathWritable'
  if [[ ! -w $PWD ]]; then
    pathColor='pathNotWritable'
  fi

  echo $(colorize $promptPath $pathColor)
}
# }}}

# Hash {{{
function getPromptHash() {
  if ! git-is-repository; then
    echo "%#"
  else
    echo "$(getPromptSubmodule)$(getPromptStash)$(getPromptHashGit)"
  fi
}
# }}}

# Stash {{{
function getPromptStash() {
  if git stash show &>/dev/null; then
    echo $(colorize '  ' 'stash')
  fi
}
# }}}

# Submodule {{{
function getPromptSubmodule() {
  if git is-submodule; then
    echo $(colorize '  ' 'submodule')
  fi
}
# }}}

# Git Hash {{{
function getPromptHashGit() {
  # Staged files
  if git-directory-has-staged-files; then
    echo $(colorize '±' 'repoStaged')
    return
  fi

  # Modified, deleted or newly added files
  if git-directory-is-dirty; then
    echo $(colorize '±' 'repoDirty')
    return
  fi

  echo $(colorize '±' 'repoClean')
}
# }}}

# Repo indicator {{{
function getPromptRepoIndicator() {
  if ! git-is-repository; then
    echo ""
  else
    echo "$(getPromptTag)$(getPromptRebase)$(getPromptRemote)$(getPromptBranch)"
  fi
}
# }}}

# Remote {{{
function getPromptRemote() {
  local remoteName="$(git remote-current)"
  local remoteColor='remoteDefault'

  # Default remote
  if [[ $remoteName = 'origin' || $remoteName == '' ]]; then
    return;
  fi

  if [[ $remoteName == 'heroku' ]]; then
    remoteColor='remoteHeroku'
  fi
  if [[ $remoteName == 'github' ]]; then
    remoteColor='remoteGithub'
  fi
  if [[ $remoteName == 'upstream' ]]; then
    remoteColor='remoteUpstream'
  fi

  echo $(colorize "$remoteName " $remoteColor)
}
# }}}

# Branch {{{
function getPromptBranch() {
  local branchName="$(git branch-current)"
  local branchColor='branchDefault'

  # Not in a branch
  if [[ $branchName = '' ]]; then
    return;
  fi

  # In detached head, we stop now
  if [[ $branchName = 'HEAD' ]]; then
    branchColor='branchDetached'
    branchName="$(git commit-current) "
    echo $(colorize $branchName $branchColor)
    return
  fi

  if [[ $branchName = 'master' ]]; then
    branchColor='branchMaster'
  fi
  if [[ $branchName = 'release' ]]; then
    branchColor='branchRelease'
  fi
  if [[ $branchName = 'develop' ]]; then
    branchColor='branchDevelop'
  fi
  if [[ $branchName =~ '^feature/' ]]; then
    branchColor='branchFeature'
    branchName=${branchName//feature\//}
  fi
  if [[ $branchName =~ '^(bugfix|hotfix|fix)/' ]]; then
    branchColor='branchFix'
    branchName="${branchName//bugfix\//}"
    branchName="${branchName//hotfix\//}"
    branchName="${branchName//fix\//}"
    branchName="${branchName} "
  fi
  if [[ $branchName =~ '^review/' ]]; then
    branchColor='branchReview'
    branchName="${branchName//review\//}  "
  fi
  if [[ $branchName =~ '^test/' ]]; then
    branchColor='branchTest'
    branchName="${branchName//test\//} "
  fi
  if [[ $branchName =~ '^perf/' ]]; then
    branchColor='branchPerf'
    branchName="${branchName/perf\//} "
  fi
  if [[ $branchName = 'gh-pages' ]]; then
    branchColor='branchGhPages'
    branchName="$branchName  "
  fi

  # Adding push/pull indicator
  local pushPullSymbol="$(getPromptPushPull)"
  if [[ $pushPullSymbol != '' ]]; then
    branchName="${pushPullSymbol} ${branchName}"
  fi

  echo $(colorize $branchName $branchColor)
}
# }}}

# Push/Pull {{{
function getPromptPushPull() {
  local EXIT_CODE_IDENTICAL=0
  local EXIT_CODE_AHEAD=1
  local EXIT_CODE_BEHIND=2
  local EXIT_CODE_DIVERGED=3
  local EXIT_CODE_NEVER_PUSHED=4
  local remoteStatus
  remoteStatus="$(git-branch-remote-status)$?"

  case "$remoteStatus" in
    $EXIT_CODE_AHEAD)
      echo " "
      ;;
    $EXIT_CODE_BEHIND)
      echo " "
      ;;
    $EXIT_CODE_DIVERGED)
      echo " "
      ;;
    $EXIT_CODE_NEVER_PUSHED)
      echo ""
      ;;
  esac
}
# }}}

# Tag {{{
function getPromptTag() {
  local tagName="$(git tag-current)"
  if [[ $tagName = '' ]]; then
    return
  fi
  echo $(colorize "$tagName " 'tag')
}
# }}}

# Rebase {{{
function getPromptRebase() {
  local gitRoot="$(git root)"
  local rebaseDir="${gitRoot}/.git/rebase-apply"

  # No rebase in progress
  if [[ ! -r $rebaseDir/rebasing ]]; then
    return
  fi

  local maxRebase="$(cat $rebaseDir/last)"
  local nextRebase="$(cat $rebaseDir/next)"
  echo $(colorize "${nextRebase}/${maxRebase}   " 'rebase')
}
# }}}

# Connection indicator {{{
function getConnectionIndicator() {
  # Getting the last time we checked connectivity
  lastConnectionFile=/tmp/zsh_last_connection_check
  lastConnection="$(cat $lastConnectionFile 2>/dev/null)"
  if [[ $lastConnection == '' ]]; then
    lastConnection=0
  fi

  # No need to check if it's less than 5 min
  now="$(date +%s)"
  if [[ $(($now-$lastConnection)) -lt $((5*60)) ]]; then
    echo "--"
    return
  fi
  # Save new check date
  date +%s > $lastConnectionFile

  ping -c 1 8.8.8.8 &>/dev/null || echo $(colorize " " 'noConnection')
}
# }}}

# chpwd() {{{
function chpwd() {
  # Set current path as the window title
  print -Pn "\e]2;%~/\a"
}
# }}}

# Highlighting as I type {{{
source ./plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
ZSH_HIGHLIGHT_STYLES[default]="fg=$promptColor[commandText]"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$promptColor[commandCommand]"
ZSH_HIGHLIGHT_STYLES[command]="fg=$promptColor[commandCommand]"
ZSH_HIGHLIGHT_STYLES[alias]="fg=$promptColor[commandAlias]"
ZSH_HIGHLIGHT_STYLES[function]="fg=$promptColor[commandAlias]"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$promptColor[commandError]"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$promptColor[commandKeyword]"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$promptColor[commandArgument]"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$promptColor[commandArgument]"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$promptColor[commandString]"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$promptColor[commandString]"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$promptColor[commandString]"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$promptColor[commandSeparator]"
ZSH_HIGHLIGHT_STYLES[path]="fg=$promptColor[commandPath]"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=$promptColor[commandPathIncomplete]"
ZSH_HIGHLIGHT_STYLES[precommand]=none
ZSH_HIGHLIGHT_STYLES[hashed-command]=none
ZSH_HIGHLIGHT_STYLES[path_approx]=none
ZSH_HIGHLIGHT_STYLES[globbing]=none
ZSH_HIGHLIGHT_STYLES[history-expansion]=none
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[assign]=none
# }}}
