# Fancy prompt.

# init
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

PROMPT='${promptUsername}$(getPromptExitCode)${promptHostname}:$(getPromptPath) $(getPromptHash) '
RPROMPT='$(getPromptRepoIndicator)'

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
    echo $(getPromptHashGit)
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
    echo "$(getPromptTag)$(getPromptSubmodule)$(getPromptStash)$(getPromptRebase)$(getPromptBranch)"
  fi
}
# }}}

# Branch {{{
function getPromptBranch() {
  local branchName="$(git current-branch)"
  local branchColor='branchDefault'

  # Not in a branch
  if [[ $branchName = '' ]]; then
    return;
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
    branchName="$branchName "
  fi
  if [[ $branchName = 'HEAD' ]]; then
    branchColor='branchDetached'
    branchName="$(git log --pretty=format:'%h' -n 1) ⭠ "
  fi

  # Add an indicator telling us if we need to push/pull
  local pushPull="$(getPromptPushPull)"
  if [[ $pushPull != '' ]]; then
    branchName="$pushPull $branchName"
  fi

  echo $(colorize $branchName $branchColor)
}
# }}}

# Push/Pull {{{
function getPromptPushPull() {
  # No indicator if in detached HEAD
  if [[ "$(git current-branch)" = 'HEAD' ]]; then
    return
  fi

  # Branch is equal to remote
  if git-branch-is-equal-to-remote; then
    return
  fi

  # Branch was never pushed before
  if ! git-branch-has-remote; then
    echo ""
    return
  fi

  # Branch has new commits ready to be pushed
  if git-branch-is-ahead-of-remote; then
    echo " "
    return
  fi

  # Branch has diverged from remote
  if git-branch-has-diverged-from-remote; then
    echo " "
    return
  fi

  # Local branch is behind remote
  if git-branch-is-behind-remote; then
    echo " "
    return
  fi
}
# }}}

# Tag {{{
function getPromptTag() {
  local tagName="$(git current-tag)"
  if [[ $tagName = '' ]]; then
    return
  fi
  echo $(colorize "$tagName " 'tag')
}
# }}}

# Submodule {{{
function getPromptSubmodule() {
  if git is-submodule; then
    echo $(colorize '  ' 'submodule')
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

# chpwd() {{{
function chpwd() {
  # Set current path as the window title
  print -Pn "\e]2;%~/\a"
}
# }}}
