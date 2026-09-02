# Keep a reference to the last command exit code as it will probably be
# overwritten by our other functions

function oroshi-last-command-exit-store() {
  OROSHI_LAST_COMMAND_EXIT="$?"
}
