# Display all tags pointing to a specific commit
function git-tag-current-all() {
  local commit=$1
  if [[ "$commit" == '' ]]; then
    commit='HEAD'
  fi
  git tag --points-at $commit
}
