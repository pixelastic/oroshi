# Ctrl-Shift-I: Search for past Claude sessions
oroshi-fzf-claude-sessions-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  export PROMPT_PREVENT_REFRESH="1"
  local selection="$(fzf-claude-sessions)"
  export PROMPT_PREVENT_REFRESH="0"

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  LBUFFER="claude-session-resume '${selection}'"
  zle accept-line

  return 0
}
zle -N oroshi-fzf-claude-sessions-widget
bindkey 'Ⓘ' oroshi-fzf-claude-sessions-widget
