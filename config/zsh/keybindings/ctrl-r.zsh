# Ctrl-R to search in the history
oroshi-ctrl-r-widget() {
  BUFFER="$(fzf-history)"
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-r-widget
bindkey '^R' oroshi-ctrl-r-widget
# }}}
