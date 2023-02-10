# Check if at tag exists
# Usage:
# $ git-tag-exists v1.0   # Checks if specified tag exists
function git-tag-exists() {
  local tagName="$1"
  if [[ "$tagName" == '' ]]; then
    echo "✘ You must pass the name of a tag"
    return 1
  fi

  # To see if the tag exists, we list all tags matching the name. If it outputs
  # nothing, it means the tag doesn't exist.
  local output="$(git tag -l "$tagName")"
  if [[ $output == "" ]]; then
    return 1
  fi
  return 0
}
