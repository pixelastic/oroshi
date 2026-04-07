# Ctrl-i opens an AI chat window
oroshi-claude-widget() {
  LBUFFER="claude"
  zle accept-line
  return 0
}
zle -N oroshi-claude-widget
bindkey '⒤' oroshi-claude-widget
# }}}
