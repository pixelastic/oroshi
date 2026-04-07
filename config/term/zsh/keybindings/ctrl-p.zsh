# Ctrl-P: Search for something specific (usually a file), based on typed command
oroshi-fzf-command-specific-widget() {
  # Stop if not available
  if ! command -v fzf >/dev/null; then
    echo "fzf is not installed"
    zle reset-prompt
    return
  fi

  # Save LBUFFER in a variable
  # Used by fzf-fs-shared-zsh-filters to adapt its filters
  fzf-var-write ZSH_LBUFFER "${LBUFFER}"

  # Command-specific
  local commandName="default"
  [[ "${LBUFFER}" =~ "vfa( )?$" ]] && commandName="vfa"

  # Suggest selection
  export PROMPT_PREVENT_REFRESH="1"
  selection="$(oroshi-fzf-command-specific-${commandName}-selection)"
  export PROMPT_PREVENT_REFRESH="0"

  # Cleanup
  fzf-var-write ZSH_LBUFFER ""

  # Stop if no selection is made
  [[ "$selection" == "" ]] && return 1

  # What to do with the selection
  LBUFFER="${LBUFFER}${selection} "

  return 0
}
zle -N oroshi-fzf-command-specific-widget
bindkey '^P' oroshi-fzf-command-specific-widget

# Default
function oroshi-fzf-command-specific-default-selection {
  fzf-fs-files-project
}

# git add / vfa
function oroshi-fzf-command-specific-vfa-selection {
  fzf-git-files-stageable
}
