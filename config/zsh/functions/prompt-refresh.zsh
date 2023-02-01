# Refresh the current prompt
# Works by sending a TRAPUSR1 signal to it
# Usage:
# $ prompt-refresh           # Guesses the topmost zsh process
# $ prompt-refresh 1794568   # Specify the prompt to refresh.
#                            # Useful when running background processes,
#                            # detached from the prompt
function prompt-refresh() {
  local promptPid="$1"
  if [[ $promptPid == '' ]]; then
    promptPid="$(prompt-pid)"
  fi

  kill -s USR1 $promptPid
}
