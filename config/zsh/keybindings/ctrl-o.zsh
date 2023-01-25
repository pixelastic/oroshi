# Ctrl-O fuzzy find in sub directories
oroshi-fzf-subdirectories-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-directories)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    zle reset-prompt
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-subdirectories-widget
bindkey '^O' oroshi-fzf-subdirectories-widget
