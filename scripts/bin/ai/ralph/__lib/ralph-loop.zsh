# Run ralph in loop mode — N iterations with auto-commit after each
#
# Usage:
# $ ralph-loop <dir> <maxLoops>

# Guard: skip if already defined (e.g. mocked in tests)
whence ralph-loop >/dev/null && return 0

WATCHER_INTERVAL="${RALPH_WATCHER_INTERVAL:-5}"
# In tests, set RALPH_TTY=/dev/null — /dev/tty requires a real terminal and will fail otherwise
TTY_INPUT="${RALPH_TTY:-/dev/tty}"

# Kill claude when state.done becomes true
_sentinel_watcher() {
  local dir="$1"
  local claudePid="$2"
  while true; do
    sleep $WATCHER_INTERVAL
    [[ ! "$(ralph-state "$dir" get 'done')" == "true" ]] && continue
    kill -TERM $claudePid 2>/dev/null || true
    break
  done
}

ralph-loop() {
  setopt local_options err_return
  local dir="$1"
  local maxLoops="$2"

  # Move to repo root first, so claude has access to the whole repo
  local gitRoot="$(git-directory-root)"
  cd "$gitRoot"

  ralph-state "$dir" init loop

  local i=0
  while [[ $i -lt $maxLoops ]]; do
    i=$((i + 1))

    # PRD complete: exit loop early
    if [[ "$(ralph-state "$dir" get prd_done)" == "true" ]]; then
      print "ralph: PRD complete — all issues done"
      ralph-state "$dir" clear
      return 0
    fi

    # Reset done flag for this iteration
    ralph-state "$dir" set 'done' false

    # Start claude in background; connect to terminal when available for TUI
    claude --permission-mode acceptEdits "/ralph ${dir}" <"$TTY_INPUT" &
    local claudePid=$!

    _sentinel_watcher "$dir" $claudePid &
    local watcherPid=$!

    # Wait for claude; capture exit code
    local claudeExitCode=0
    wait $claudePid 2>/dev/null || claudeExitCode=$?

    # Sentinel kills the wrapper (not real claude), so we need to manually clean
    # the terminal
    claude-terminal-fix

    # Kill watcher, wait for cleanup
    kill $watcherPid 2>/dev/null || true
    wait $watcherPid 2>/dev/null || true

    # Ctrl+C: stop loop cleanly, no commit
    if [[ $claudeExitCode -eq 130 ]]; then
      print "ralph: stopped (Ctrl+C)"
      ralph-state "$dir" clear
      return 0
    fi

    # Commit if there are changes
    if [[ "$(git status --porcelain)" != "" ]]; then
      git add --all
      local msg="$(git-commit-message)"
      git commit -m "$msg"
    fi
  done

  ralph-state "$dir" clear
  print "ralph: done ($maxLoops iterations)"
  claude-terminal-fix
}
