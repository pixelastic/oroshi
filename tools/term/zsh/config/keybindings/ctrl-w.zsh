# Ctrl-W: Watch changed files, then come back to the current command line

function oroshi-ctrl-w-widget() {
  run-command-silent git-file-watch
}
zle -N oroshi-ctrl-w-widget
bindkey '^W' oroshi-ctrl-w-widget
