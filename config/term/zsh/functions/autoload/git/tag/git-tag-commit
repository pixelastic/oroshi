# Displays the commit the specified tag points to
# Usage:
# $ git-tag-commit v1.0
function git-tag-commit() {
  # Tag name
  local tagName="$1"
  if [[ $tagName == '' ]]; then
    tagName="$(git-tag-current)"
  fi

  local commitHash="$(git rev-list --abbrev-commit -1 "$tagName" 2>/dev/null)"

  # Error if can't find the commit
  if [[ $commitHash = '' ]]; then
    return 1
  fi
  echo $commitHash
}

