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
  if [[ "${LBUFFER}" =~ "vfa( )?$" ]]; then
    selection="$(fzf-git-files-dirty)"
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

  LBUFFER="${LBUFFER}${selection} "
  return 0
}
zle -N oroshi-fzf-files-project-widget
bindkey '^P' oroshi-fzf-files-project-widget
