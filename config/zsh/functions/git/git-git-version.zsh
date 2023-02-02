# Display the current git version
function git-git-version() {
  git --version | awk '{print $3}'
}
