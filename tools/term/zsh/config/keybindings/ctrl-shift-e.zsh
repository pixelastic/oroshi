# Ctrl-Shift-E copies current command line to clipboard
oroshi-copy-current-command-widget() {
  clipboard-write "$BUFFER"
  zle reset-prompt
  return 0
}
zle -N oroshi-copy-current-command-widget
bindkey 'Ⓔ' oroshi-copy-current-command-widget
