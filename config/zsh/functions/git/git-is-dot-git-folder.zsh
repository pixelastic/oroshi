# Check if currently in a .git folder
function git-is-dot-git-folder {
  local response="$(git rev-parse --is-inside-git-dir 2>/dev/null)"

  [[ "$response" == "true" ]] && return 0
  return 1
}
