# Ctrl-O fuzzy find in sub directories
oroshi-ctrl-o-widget() {
  LBUFFER="${LBUFFER}$(fzf-directories) "
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-o-widget
bindkey '^O' oroshi-ctrl-o-widget
