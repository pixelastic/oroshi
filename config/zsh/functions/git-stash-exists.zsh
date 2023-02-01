# Check if the current directory has at least one stash
# Usage:
# $ git-stash-exists
function git-stash-exists() {
  git stash show &>/dev/null && return 0
  return 1
}
