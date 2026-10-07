# Ctrl-L lists all files in the directory
function oroshi-ctrl-l-widget() {
  run-command-silent ls
}
zle -N oroshi-ctrl-l-widget
bindkey '^L' oroshi-ctrl-l-widget
