# Displays the status of the specific tag, relative to the specified commit
# Usage:
# $ git-tag-status v1.0 abc123  # Status of the tag related to the commit
# $ git-tag-status v1.0         # Status of the tag related to current commit
# $ git-tag-status              # Status of the current related to current commit

# Possible status are:
# - exact
#   The tag refers exactly to the specified commit
#
# - closest
#   The tag is the closest defined tag in the current branch
#
# - parent
#   The tag refers to a commit in the current branch
#
# - unrelated
#   The tag is not in the current branch at all
#
# - unknown
#   The tag does not exist at all
function git-tag-status() {
  local currentTag="$(git-tag-current)"
  local currentCommit="$(git-commit-current)"

  # Tag name
  local tagName="$1"
  if [[ $tagName == '' ]]; then
    tagName="$currentTag"
  fi

  # Commit Hash
  local commitHash="$2"
  if [[ $commitHash == '' ]]; then
    commitHash="$currentCommit"
  fi

  # Quickly stop if tag does not exist
  if ! git-tag-exists "$tagName"; then
    echo "unknown"
    return 0
  fi

  # Exact
  # The current commit is exactly where the specified commit points to
  local tagCommit="$(git-tag-commit $tagName)"
  if [[ "$currentCommit" = "$tagCommit" ]]; then
    echo "exact"
    return 0
  fi

  local branchTags=($(git tag --sort=-committerdate --merged "$commitHash"))

  # Closest
  # The specified tag is exactly the first one in the list of tags of this branch
  if [[ "$tagName" = "$branchTags[1]" ]]; then
    echo "closest"
    return 0
  fi

  # Parent
  # The specified tag is in the list of tags of this branch
  for branchTag in $branchTags; do
    if [[ "$tagName" = "$branchTag" ]]; then
      echo "parent"
      return 0
    fi
  done

  echo "unrelated"
}
