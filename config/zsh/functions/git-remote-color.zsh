# Return the string color of a specific remote
# Usage:
# $ git-remote-color             # (current remote) blue
# $ git-remote-color upstream    # blue
function git-remote-color() {

  # Remote name
  local remoteName="$1"
  if [[ $remoteName == '' ]]; then
    remoteName="$(git-remote-current)"
  fi

  local DEFAULT_REMOTE_COLOR='YELLOW'

  declare -A REMOTE_COLORS
  REMOTE_COLORS=()
  REMOTE_COLORS[HEAD]='RED'
  REMOTE_COLORS[algolia]='BLUE_4'
  REMOTE_COLORS[origin]='YELLOW'
  REMOTE_COLORS[pixelastic]='GREEN'
  REMOTE_COLORS[upstream]='BLUE'

  # Remote doesn't exist
  if ! git-remote-exists "$remoteName"; then
    echo RED
    return
  fi

  # Known remote
  local knownColor=$REMOTE_COLORS[$remoteName]
  if [[ $knownColor != '' ]]; then
    echo $knownColor
    return
  fi


  # Default remote
  echo $DEFAULT_REMOTE_COLOR
}
