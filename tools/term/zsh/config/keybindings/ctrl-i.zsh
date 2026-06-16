# Ctrl-i opens an AI chat window
oroshi-ctrl-i-widget() {
  LBUFFER="claude"
  zle accept-line
  return 0
}
zle -N oroshi-ctrl-i-widget
bindkey '⒤' oroshi-ctrl-i-widget
# }}}
