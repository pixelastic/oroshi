# Check if the remote repository is hosted on GitHub
# Usage:
# $ git-directory-is-github
function git-directory-is-github() {
  # If the remote url contains github.com, we can assume it's pointing to GitHub
  git-remote-url | grep -q "github.com"
}

