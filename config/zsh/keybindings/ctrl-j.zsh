# Ctrl-J fuzzy find in common directories
oroshi-fzf-common-directories-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-directories-common)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    zle reset-prompt
    return 1
  fi

  # Move to that directory
  LBUFFER="${LBUFFER}${selection} "
  zle reset-prompt
  return 0
}
zle -N oroshi-fzf-common-directories-widget
bindkey '^J' oroshi-fzf-common-directories-widget
