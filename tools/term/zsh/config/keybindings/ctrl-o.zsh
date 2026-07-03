# Ctrl-O: Search for a directory in current git project
# Dispatches to a context-aware picker based on the last word in LBUFFER

oroshi-ctrl-o-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  typeset -gA specialPickers
  specialPickers=(
    ralph fzf-plans
    raplh fzf-plans
  )

  # Dispatch to context-aware picker based on last word in buffer
  local bufferWords=(${(z)LBUFFER})
  local lastWord="${bufferWords[-1]}"
  local picker="${specialPickers[$lastWord]}"
  [[ "$picker" == "" ]] && picker="ctrl-o"

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$($picker)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  LBUFFER="${LBUFFER}${(q-)selection} "
  return 0
}
zle -N oroshi-ctrl-o-widget
bindkey '^O' oroshi-ctrl-o-widget
