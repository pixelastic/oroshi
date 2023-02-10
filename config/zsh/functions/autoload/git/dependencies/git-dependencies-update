# Update project dependencies if changed since specified commit
# Should be run when switching branches
#
# Usage:
# $ git-dependencies-update d34db33f
function git-dependencies-update() {
  local originCommit=$1

  git submodule update

  git-dependencies-update-node $originCommit
  git-dependencies-update-ruby $originCommit
}
