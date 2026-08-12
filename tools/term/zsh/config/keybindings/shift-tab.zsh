# Shift-Tab: Completion through fzf
source "$HOME/local/etc/fzf-tab/fzf-tab.zsh"
local fzfAutoload="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fzf"
source "$fzfAutoload/__lib/fzf-options-prompt-label.zsh"

# Loading fzf-tab automatically bind it to Tab (^I), so we revert it to the
# regular completion widget
bindkey '^I' oroshi-tab-widget

# Ensure fzf-tab uses our default options
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# fzf-tab forces some specific options we don't like, so we overwrite them here
# manually
zstyle ':fzf-tab:*' fzf-flags \
  --height=100% \
  --bind=ctrl-space:toggle+down \
  "--prompt=$(fzf-options-prompt-label fzf-completion Completion gray white)"

function oroshi-shift-tab-widget() {
  # No-op when nothing is typed
  [[ "$LBUFFER" == "" ]] && return 0

  # Custom fzf pickers dispatched before fzf-tab
  local -A specialPickers=(
    vcR fzf-git-commits
    vcRa fzf-git-commits
    vfresurrect fzf-git-files-deleted
  )

  # Dispatch to custom fzf picker if one exists for this command
  local bufferWords=(${(z)LBUFFER})
  local lastWord="${bufferWords[-1]}"
  local picker="${specialPickers[$lastWord]}"

  export PROMPT_PREVENT_REFRESH="1"

  if [[ "$picker" != "" ]]; then
    local selection="$($picker)"
    export PROMPT_PREVENT_REFRESH="0"
    [[ "$selection" == "" ]] && return 0
    LBUFFER="${LBUFFER}${selection} "
    return 0
  fi

  # Default: fzf-tab completion
  zle fzf-tab-complete
  export PROMPT_PREVENT_REFRESH="0"
  return 0
}
zle -N oroshi-shift-tab-widget
bindkey '^[[Z' oroshi-shift-tab-widget
# }}}
