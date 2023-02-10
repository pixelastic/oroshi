# Check if a remote exists
# Usage:
# $ git-remote-exists            # Checks if current remote is defined
# $ git-remote-exists upstream   # Checks if remote named upstream is defined
function git-remote-exists() {
  # Check if the remote has a URL, if not, it is not configured
  git-remote-url $1 &>/dev/null || return 1
  return 0
}
