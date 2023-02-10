# Displays a colorized version of a branch name
# Usage:
# $ git-branch-colorize                    # {currentBranch}
# $ git-branch-colorize master             # master
# $ git-branch-colorize --with-icon        #  master
function git-branch-colorize() {
  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Branch name {{{
  local branchName="$argsp[1]"
  # Default to current branch if none specified
  if [[ "$branchName" == '' ]]; then
    branchName="$(git-branch-current)"
  fi
  # }}}
  # Branch color
  local branchColor="$(git-branch-color $branchName)"

  # If --with-icon is not passed, we simply display the colored branch
  if [[ "$argsf[--with-icon]" != 1 ]]; then
    colorize "$branchName" $branchColor
    return
  fi

  # If --with-icon is passed, we need to add an icon and display a specific
  # color based on the local/remote relationship
  local branchPushStatus="$(git-branch-push-status $branchName)"

  if [[ $branchPushStatus = 'never_pushed' ]]; then
    colorize " $branchName" $branchColor
    return
  fi

  if [[ $branchPushStatus = 'identical' ]]; then
    colorize "$branchName" $branchColor
    return
  fi

  if [[ $branchPushStatus = 'ahead' ]]; then
    colorize " $branchName" BLUE
    return
  fi

  if [[ $branchPushStatus = 'behind' ]]; then
    colorize " $branchName" BLUE_LIGHT
    return
  fi

  if [[ $branchPushStatus = 'gone' ]]; then
    colorize " $branchName" RED_LIGHT
    return
  fi

  if [[ $branchPushStatus = 'diverged' ]]; then
    colorize " $branchName" RED
    return
  fi

  if [[ $branchPushStatus = 'detached' ]]; then
    local currentCommit="$(git-commit-current)"
    colorize " HEAD ($currentCommit)" RED
    return
  fi

  # Fallback on unknown status
  colorize " $branchName" $branchColor
  return
}
