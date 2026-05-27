# Ctrl-J: Search for a specific directory, from all known locations
oroshi-fzf-common-directories-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-fs-directories-common)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  # Add the path to the buffer
  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-common-directories-widget
bindkey '⒥' oroshi-fzf-common-directories-widget
