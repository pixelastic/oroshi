# Display remote of a given branch
# Usage:
# $ git-branch-remote         # Name of current remote
# $ git-branch-remote master  # Name of current master remote
function git-branch-remote() {
  local branchName="$1"
  if [[ "$branchName" == '' ]]; then
    branchName="$(git-branch-current)"
  fi

  # Read the origin from the current branch config
  local remoteName="$(git config "branch.${branchName}.remote")"
  if [[ $remoteName != "" ]]; then
    echo $remoteName
    return 0
  fi

  # If the branch has never been pushed, there is no remote configured, so we'll
  # assume it's "origin"
  echo "origin"
}


