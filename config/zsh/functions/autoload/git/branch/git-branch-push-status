# Check the status of the current branch against its remote counterpart.
# Usage:
# $ git-branch-push-status
# $ git-branch-push-status branch
#
# Possible values are:
# - never_pushed
#   Local branch is brand new and has never been pushed
#
# - identical
#   Both local and remote are exactly the same
#
# - ahead
#   Local branch is ahead of remote branch
#
# - behind
#   Local branch is behind remote branch
#
# - diverged
#   Local and remote have diverged
#
# - detached
#   Currently on detached mode
function git-branch-push-status() {


  local branchName=$1
  if [[ "$branchName" = '' ]]; then
    branchName="$(git-branch-current)"
  fi

  # Not in a branch, in detached mode
  if [[ $branchName = 'HEAD' ]]; then
    echo "detached"
    return
  fi

  local localHead=$(git rev-parse $branchName@{0} 2>/dev/null)
  local remoteHead=$(git rev-parse $branchName@{upstream} 2>/dev/null)

  # Local is same as remote
  if [[ "$remoteHead" = "$localHead" ]]; then
    echo "identical"
    return
  fi

  # Remote has no hash, means it never get pushed
  if [[ "$remoteHead" = '' ]]; then
    echo "never_pushed"
    return
  fi


  local remoteMergeBase=$(git merge-base $branchName@{0} $branchName@{upstream} 2>/dev/null)
  # Merge base is the same as remote, it means we are ahead
  if [[ "$remoteHead" = "$remoteMergeBase" ]]; then
    echo "ahead"
    return
  fi

  # Merge base is the same as local, it means we are behind
  if [[ "$localHead" = "$remoteMergeBase" ]]; then
    echo "behind"
    return
  fi

  # Check if the remote is gone
  if git-branch-gone $branchName; then
    echo "gone"
    return
  fi

  # Any other case means we've diverged
  echo "diverged"
}
