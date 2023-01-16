# Ctrl-P fuzzy find in files 
oroshi-fzf-subfiles-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-files)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    zle reset-prompt
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  zle reset-prompt
  return 0
}
zle -N oroshi-fzf-subfiles-widget
bindkey '^P' oroshi-fzf-subfiles-widget
