# Displays the type of the object
# Usage:
# $ git-object-type origin    # remote
# $ git-object-type master    # branch
# $ git-object-type beta      # tag
# $ git-object-type 13cd455   # commit
# $ git-object-type NONSENSE  # unknown
#
# If several types apply (technically branches and tags are commits, and
# branches and tags can share the same name), then they will be returned in the
# by order of importance as above
function git-object-type() {
  local commitRef="$1"

  # Is it a branch?
  if git-remote-exists "$commitRef"; then
    echo "remote"
    exit 0
  fi

  # Is it a branch?
  if git-branch-exists "$commitRef"; then
    echo "branch"
    exit 0
  fi

  # Is it a tag?
  if git-tag-exists "$commitRef"; then
    echo "tag"
    exit 0
  fi

  # Is it even an object?
  if git-commit-exists "$commitRef"; then
    echo "commit"
    exit 0
  fi

  # Don't know what it is
  echo "unknown"
}
