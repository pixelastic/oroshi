# Ctrl-P: Search for a file in current git project
# Dispatches to a context-aware picker based on the first word in LBUFFER

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
    yrt fzf-js-tests
    yrtw fzf-js-tests
    yrtff fzf-js-tests
    js-lint fzf-js-files
    js-fix fzf-js-files
    js-test fzf-js-tests
    go-lint fzf-go-files
    go-fix fzf-go-files
    go-test fzf-go-tests
    python-lint fzf-python-files
    python-fix fzf-python-files
    python-test fzf-python-tests
    json-lint fzf-json-files
    json-fix fzf-json-files
    markdown-lint fzf-markdown-files
    markdown-fix fzf-markdown-files
    svg-lint fzf-svg-files
    svg-fix fzf-svg-files
    toml-lint fzf-toml-files
    toml-fix fzf-toml-files
    zsh-lint fzf-zsh-files
    zsh-fix fzf-zsh-files
    zsh-test fzf-zsh-tests
    skala fzf-skills-allowlist-add
    helper-documentation fzf-helpers
    helper-description fzf-helpers
    helper-path fzf-helpers
  )

  # Dispatch to context-aware picker based on first word in buffer
  local bufferWords=(${(z)LBUFFER})
  local firstWord="${bufferWords[1]}"
  local picker="${specialPickers[$firstWord]}"
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
