# Exit code
# Display a color-coded prompt character based on the last command exit code:
# - Green if success
# - Red if error
# - Purple if any other error code
function __prompt-exit-code() {
  local exit=$OROSHI_LAST_COMMAND_EXIT;
  [[ $exit = 1 ]] && echo "%B%F{$COLOR_RED}❯ %f%b" && return
  [[ $exit > 1 ]] && echo "%F{$COLOR_PURPLE}❯ %f" && return
  echo "%F{$COLOR_GREEN}❯ %f"
}
# }}}
