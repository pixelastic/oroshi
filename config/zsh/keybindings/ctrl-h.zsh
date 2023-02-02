# Ctrl-H fuzzy find all git commits to find their hashes
oroshi-fzf-git-commit-history-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-git-commit-history)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-git-commit-history-widget
bindkey '^H' oroshi-fzf-git-commit-history-widget
