# Ctrl-R: Run ralph, then come back to the current command line

function oroshi-ctrl-r-widget() {
  run-command ralph
}
zle -N oroshi-ctrl-r-widget
bindkey '^R' oroshi-ctrl-r-widget
