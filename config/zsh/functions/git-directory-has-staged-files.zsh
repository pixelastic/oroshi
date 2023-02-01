# Check if current directory has at least one file staged.
function git-directory-has-staged-files() {
  [[ $(git diff --name-only --cached) == "" ]] && return 1
  return 0
}
