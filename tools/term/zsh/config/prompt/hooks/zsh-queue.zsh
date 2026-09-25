# Run the command queued for this Kitty window (see zsh-queue-write), as if
# typed: it lands in history, runs in the foreground and can be interrupted.
# The queue is consumed before running, so the command only runs once.

function oroshi-zsh-queue-line-init() {
  local queuedCommand="$(zsh-queue-read)"

  # Nothing queued
  [[ "$queuedCommand" == "" ]] && return 0

  zsh-queue-delete
  BUFFER="$queuedCommand"
  zle accept-line
}
