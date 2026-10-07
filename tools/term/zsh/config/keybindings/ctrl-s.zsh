# Ctrl-S: Commit all changes, then come back to the current command line

function oroshi-ctrl-s-widget() {
  run-command git-commit-create-all-auto
}
zle -N oroshi-ctrl-s-widget
bindkey '^S' oroshi-ctrl-s-widget
