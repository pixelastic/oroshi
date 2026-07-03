# Shift-Tab: Completion through fzf
source "$HOME/local/etc/fzf-tab/fzf-tab.zsh"
source "$OROSHI_ROOT/scripts/bin/fzf/__lib/fzf-options-prompt-label.zsh"

# Loading fzf-tab automatically bind it to Tab (^I), so we revert it to the
# regular completion widget
bindkey '^I' oroshi-tab-widget

zstyle ':fzf-tab:*' fzf-flags \
  --color=prompt::regular \
  "--prompt=$(fzf-options-prompt-label fzf-completion Completion gray white)"

oroshi-shift-tab-widget() {
  export PROMPT_PREVENT_REFRESH="1"
  zle fzf-tab-complete
  export PROMPT_PREVENT_REFRESH="0"
  return 0
}
zle -N oroshi-shift-tab-widget
bindkey '^[[Z' oroshi-shift-tab-widget
# }}}
