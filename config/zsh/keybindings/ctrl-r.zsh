# Ctrl-R to search in the history
oroshi-fzf-commands-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-commands)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-commands-widget
bindkey '^R' oroshi-fzf-commands-widget
# }}}
