# Ctrl-P: Search for a specific file, in the whole project or context-aware completion
oroshi-fzf-files-project-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  # Common setup
  fzf-var-write ZSH_LBUFFER "${LBUFFER}"
  export PROMPT_PREVENT_REFRESH="1"

  # Context-aware selection
  local selection=""
  local isClaudeResume=false

  if [[ "${LBUFFER}" =~ "claude( )?$" ]]; then
    selection="$(fzf-claude-sessions)"
    isClaudeResume=true
  elif [[ "${LBUFFER}" =~ "vfa( )?$" ]]; then
    selection="$(fzf-git-files-stageable)"
  else
    selection="$(fzf-fs-files-project)"
  fi

  # Common cleanup
  export PROMPT_PREVENT_REFRESH="0"
  fzf-var-write ZSH_LBUFFER ""

  # Stop if no selection is made
  if [[ "$selection" == "" ]]; then
    return 1
  fi

  # Special handling for Claude session resume
  if [[ $isClaudeResume == true ]]; then
    local parts=(${(@s/▮/)selection})
    local uuid="$parts[1]"
    local cwd="$parts[2]"

    # Clear the buffer and execute resume command
    LBUFFER=""
    RBUFFER=""
    zle reset-prompt

    # Execute the resume command in original directory
    eval "cd '$cwd' && claude --resume '$uuid'"
    return 0
  fi

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-files-project-widget
bindkey '^P' oroshi-fzf-files-project-widget
