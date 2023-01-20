# Ctrl-Y fuzzy find all git commits
oroshi-fzf-git-commits-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-git-commits)"
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
zle -N oroshi-fzf-git-commits-widget
bindkey '^Y' oroshi-fzf-git-commits-widget
