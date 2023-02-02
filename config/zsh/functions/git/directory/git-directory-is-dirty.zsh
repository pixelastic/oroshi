# Check if current directory is dirty, ie. contains at least one modified,
# deleted or new file.
function git-directory-is-dirty() {
  [[ $(git status --porcelain --short -unormal) == "" ]] && return 1
  return 0
}
