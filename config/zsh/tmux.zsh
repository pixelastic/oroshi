# Launch a new tmux session or attach to latest if one already
# Quit the terminal when detaching, go to next session when closing one
function launchTmux() {
  local tmuxExitMessage="$(tmux attach || tmux new-session)"
  [[ $tmuxExitMessage == *detached* ]] && exit
  launchTmux
}
[[ -z "$TMUX" ]] && launchTmux
