# Ctrl-R to search in the history
oroshi-fzf-command-history-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-command-history)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-command-history-widget
bindkey '^R' oroshi-fzf-command-history-widget
# }}}
