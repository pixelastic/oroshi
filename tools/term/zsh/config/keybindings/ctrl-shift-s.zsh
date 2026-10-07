# Ctrl-Shift-S: Commit all changes then run ralph, as a real command so its output can be retrieved

function oroshi-ctrl-shift-s-widget() {
  run-command vcaar
}
zle -N oroshi-ctrl-shift-s-widget
bindkey 'Ⓢ' oroshi-ctrl-shift-s-widget
