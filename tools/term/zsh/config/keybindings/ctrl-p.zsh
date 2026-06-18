# Ctrl-P: Search for a file in current git project
# Dispatches to a context-aware picker based on the last word in LBUFFER

oroshi-ctrl-p-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  local -A specialPickers=(
    vfa fzf-git-files-stageable
    bats fzf-bats-test
  )

  # Dispatch to context-aware picker based on last word in buffer
  local bufferWords=(${(z)LBUFFER})
  local lastWord="${bufferWords[-1]}"
  local picker="${specialPickers[$lastWord]}"
  [[ "$picker" == "" ]] && picker="ctrl-p"

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$($picker)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-ctrl-p-widget
bindkey '^P' oroshi-ctrl-p-widget
