# Ctrl-P fuzzy find in files 
oroshi-ctrl-p-widget() {
  LBUFFER="${LBUFFER}$(fzf-files) "
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-p-widget
bindkey '^P' oroshi-ctrl-p-widget
