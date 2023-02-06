# Ctrl-Shift-P fuzzy find in directory files
oroshi-fzf-files-search-subdir-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-files-search-subdir)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-files-search-subdir-widget
bindkey 'Ⓟ' oroshi-fzf-files-search-subdir-widget
