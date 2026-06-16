# Ctrl-Shift-E copies current command line to clipboard
oroshi-ctrl-shift-e-widget() {
  clipboard-write "$BUFFER"
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-shift-e-widget
bindkey 'Ⓔ' oroshi-ctrl-shift-e-widget
