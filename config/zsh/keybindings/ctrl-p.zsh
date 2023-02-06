# Ctrl-P fuzzy find in project files
oroshi-fzf-files-search-project-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-files-search-project)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-files-search-project-widget
bindkey '^P' oroshi-fzf-files-search-project-widget
