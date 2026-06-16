# Ctrl-P: Search for something specific (usually a file), based on typed command
oroshi-ctrl-p-widget() {
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
  [[ "${LBUFFER}" =~ "bats( )?$" ]] && commandName="bats"

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
zle -N oroshi-ctrl-p-widget
bindkey '^P' oroshi-ctrl-p-widget

# Default
function oroshi-fzf-command-specific-default-selection {
  fzf-fs-files-project
}

# bats
function oroshi-fzf-command-specific-bats-selection {
  fzf-bats-test
}

# git add / vfa
function oroshi-fzf-command-specific-vfa-selection {
  fzf-git-files-stageable
}
