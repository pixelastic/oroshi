# Ctrl-F search into files in current directory
oroshi-fzf-regexp-subdir-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-regexp-subdir)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  echo $selection

  nvim -p ${=selection}

  return 0
}
zle -N oroshi-fzf-regexp-subdir-widget
bindkey '^F' oroshi-fzf-regexp-subdir-widget
