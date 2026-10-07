# Ctrl-Shift-S: Commit all changes, run ralph if it succeeded, then come back to the current command line

# run-command runs a single command, so chain both here to reset the prompt only once
function oroshi-commit-then-ralph() {
  git-commit-create-all-auto && ralph
}

function oroshi-ctrl-shift-s-widget() {
  run-command oroshi-commit-then-ralph
}
zle -N oroshi-ctrl-shift-s-widget
bindkey 'Ⓢ' oroshi-ctrl-shift-s-widget
