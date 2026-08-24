# Ctrl-P: Search for a file in current git project
# Dispatches to a context-aware picker based on the last word in LBUFFER

function oroshi-ctrl-p-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  local -A specialPickers=(
    vfa fzf-git-files-dirty-stageable
    vfrevert fzf-git-files-dirty
    bats fzf-bats-test
    yrt fzf-js-test
    yrtw fzf-js-test
    yrtff fzf-js-test
    go-lint fzf-go-files
    go-fix fzf-go-files
    go-test fzf-go-tests
    json-lint fzf-json-files
    json-fix fzf-json-files
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

  local -a paths=("${(f)selection}")
  local inlineSelection="${(j: :)${(q-)paths[@]}}"
  LBUFFER="${LBUFFER}${inlineSelection} "
  return 0
}
zle -N oroshi-ctrl-p-widget
bindkey '^P' oroshi-ctrl-p-widget
