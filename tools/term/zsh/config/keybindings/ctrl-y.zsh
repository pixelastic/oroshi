# Ctrl-Y copies current directory to clipboard
oroshi-ctrl-y-widget() {
  clipboard-write "$PWD"
  zle reset-prompt
  return 0
}
zle -N oroshi-ctrl-y-widget
bindkey '^Y' oroshi-ctrl-y-widget

