# Ctrl-S: Commit all changes, as a real command so its output can be retrieved

function oroshi-ctrl-s-widget() {
  run-command vcaa
}
zle -N oroshi-ctrl-s-widget
bindkey '^S' oroshi-ctrl-s-widget
