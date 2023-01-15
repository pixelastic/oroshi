# Ctrl-O fuzzy find in sub directories
oroshi-ctrl-o-widget() {
  local selection="$(fzf-directories)"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    zle reset-prompt
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-o-widget
bindkey '^O' oroshi-ctrl-o-widget
