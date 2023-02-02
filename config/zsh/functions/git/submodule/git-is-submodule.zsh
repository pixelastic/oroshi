# Check if current directory is a submodule
function git-is-submodule() {
  # We do that by going one level higher and checking if it's also a git
  # directory
  (
    cd "$(git pwd)/.."
    git-directory-is-repository
  )
}
