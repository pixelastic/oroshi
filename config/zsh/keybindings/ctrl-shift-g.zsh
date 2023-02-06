# Ctrl-Shift-G search into files in current directory
oroshi-fzf-regexp-search-subdir-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-regexp-search-subdir)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  echo $selection

  nvim -p ${=selection}

  return 0
}
zle -N oroshi-fzf-regexp-search-subdir-widget
bindkey 'Ⓖ' oroshi-fzf-regexp-search-subdir-widget
