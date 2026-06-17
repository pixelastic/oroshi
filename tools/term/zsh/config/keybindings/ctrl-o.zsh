# Ctrl-O: Search for a directory in current git project
oroshi-ctrl-o-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(ctrl-o)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-ctrl-o-widget
bindkey '^O' oroshi-ctrl-o-widget
