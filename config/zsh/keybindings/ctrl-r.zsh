# Ctrl-R to search in the history
oroshi-ctrl-r-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  BUFFER="$(fzf-history)"
  export PROMPT_PREVENT_REFRESH="0"

  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-r-widget
bindkey '^R' oroshi-ctrl-r-widget
# }}}
