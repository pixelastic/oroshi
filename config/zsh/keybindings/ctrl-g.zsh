# Ctrl-G search into files
oroshi-fzf-regexp-search-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-regexp-search)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  nvim -p ${=selection}

  return 0
}
zle -N oroshi-fzf-regexp-search-widget
bindkey '^G' oroshi-fzf-regexp-search-widget
