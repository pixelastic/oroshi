# Ctrl-O: Search for a specific directory, context-aware based on typed command
oroshi-ctrl-o-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  # Command-specific
  local completionType="default"
  [[ "${LBUFFER}" =~ "ralph( )?$" ]] && completionType="plans"
  [[ "${LBUFFER}" =~ "raplh( )?$" ]] && completionType="plans"

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(oroshi-fzf-directories-${completionType}-selection)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-ctrl-o-widget
bindkey '^O' oroshi-ctrl-o-widget

# Default: all project directories
function oroshi-fzf-directories-default-selection {
  fzf-fs-directories-project
}

# plans: plans/ subdirectories only
function oroshi-fzf-directories-plans-selection {
  fzf-fs-directories-plans
}
