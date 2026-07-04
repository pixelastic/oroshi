# Shift-Tab: Completion through fzf
source "$HOME/local/etc/fzf-tab/fzf-tab.zsh"
source "$OROSHI_ROOT/scripts/bin/fzf/__lib/fzf-options-prompt-label.zsh"

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
