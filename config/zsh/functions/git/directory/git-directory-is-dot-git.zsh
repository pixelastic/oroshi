# Check if currently in a .git folder
function git-directory-is-dot-git {
  local response="$(git rev-parse --is-inside-git-dir 2>/dev/null)"

  [[ "$response" == "true" ]] && return 0
  return 1
}
