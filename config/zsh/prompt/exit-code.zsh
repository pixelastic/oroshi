# Exit code
# Display a color-coded prompt character based on the last command exit code:
# - Green if success
# - Red if error
# - Purple if any other error code
function __prompt-exit-code() {
  local exit=$OROSHI_LAST_COMMAND_EXIT;
  [[ $exit = 1 ]] && echo "%B%F{$COLORS[red]}❯ %f%b" && return
  [[ $exit > 1 ]] && echo "%F{$COLORS[purple]}❯ %f" && return
  echo "%F{$COLORS[green]}❯ %f"
}
# }}}
