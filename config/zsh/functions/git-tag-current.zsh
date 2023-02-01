# Display name of current tag
# Usage:
# $ git-tag-current         # Display name of closest tag
function git-tag-current() {
  # Note: If several tags point to the same commit, git will return the first created
  git describe --tags --abbrev=0 2>/dev/null

  # Will display the closest tag if one exists, or throw an error if not, so we
  # hide the error and always succeed the script.
  return 0
}
