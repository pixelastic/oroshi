# Check if current directory is a git repository
function git-is-repository {
  local response="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

  [[ "$response" == "true" ]] && return 0
  return 1
}
