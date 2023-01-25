# Ctrl-F fuzzy find in all projects files, with full absolute path returned
oroshi-fzf-absolute-path-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-absolute-filepath)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-absolute-path-widget
bindkey '^F' oroshi-fzf-absolute-path-widget
