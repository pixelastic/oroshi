# Check if the specified branch has its upstream gone
# Usage:
# $ git-branch-gone           # Uses current branch
# $ git-branch-gone develop   # Uses develop branch
function git-branch-gone() {
  local branchName="$1"
  if [[ $branchName = '' ]]; then
    branchName="$(git-branch-current)"
  fi

  # Can't be gone if doesn't exist
  if ! git-branch-exists "$branchName"; then
    return 1
  fi

  # See if it matches:
  #   branchName aze5c87 [path/to/origin: gone]
  git branch --list -vv | grep "^..${branchName}\( *\)\(.*\) \[\(.*\): gone\]" &>/dev/null
}
