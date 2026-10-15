# Ctrl-Shift-W: Watch changed files since the start of the worktree
function oroshi-ctrl-shift-w-widget() {
  run-command-silent git-file-watch-worktree
}
zle -N oroshi-ctrl-shift-w-widget
bindkey 'Ⓦ' oroshi-ctrl-shift-w-widget
