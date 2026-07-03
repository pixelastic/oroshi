# Shift-Tab: Completion through fzf
source "$HOME/local/etc/fzf-tab/fzf-tab.zsh"
source "$OROSHI_ROOT/scripts/bin/fzf/__lib/fzf-options-prompt-label.zsh"

# Loading fzf-tab automatically bind it to Tab (^I), so we revert it to the
# regular completion widget
bindkey '^I' oroshi-tab-widget

# Inherit our global fzf config — fzf-tab ignores FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# fzf-tab's --bind overrides FZF_DEFAULT_OPTS for the same keys;
# fzf-flags comes last so these win back
zstyle ':fzf-tab:*' fzf-flags \
  --height=100% \
  --bind=ctrl-space:toggle+down \
  "--prompt=$(fzf-options-prompt-label fzf-completion Completion gray white)"

oroshi-shift-tab-widget() {
  # No-op when nothing is typed — would dump every command/file otherwise
  [[ "$LBUFFER" == "" ]] && return 0
  export PROMPT_PREVENT_REFRESH="1"
  zle fzf-tab-complete
  export PROMPT_PREVENT_REFRESH="0"
  return 0
}
zle -N oroshi-shift-tab-widget
bindkey '^[[Z' oroshi-shift-tab-widget
# }}}
