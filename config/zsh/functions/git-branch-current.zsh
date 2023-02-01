# Display name of current branch
# Usage:
# $ git-branch-current     # master
function git-branch-current() {
  git rev-parse --abbrev-ref HEAD
}

