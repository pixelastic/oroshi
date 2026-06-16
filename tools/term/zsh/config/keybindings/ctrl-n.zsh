# Ctrl-N opens current folder in explorer
oroshi-ctrl-n-widget() {
  (nohup nautilus "$PWD" &>/dev/null &)
  return 0
}
zle -N oroshi-ctrl-n-widget
bindkey '^N' oroshi-ctrl-n-widget
