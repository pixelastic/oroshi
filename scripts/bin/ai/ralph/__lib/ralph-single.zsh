# Run a single ralph session
#
# Usage:
# $ ralph-single <dir>    # Run a single ralph session on the plan dir

# Guard: skip if already defined (e.g. mocked in tests)
whence ralph-single >/dev/null && return 0

ralph-single() {
  setopt local_options err_return
  local dir="$1"

  # Refuse if a single session is already running
  if [[ -f "$dir/ralph.json" ]]; then
    local existingMode="$(ralph-state "$dir" get mode)"
    if [[ "$existingMode" == "single" ]]; then
      print "ralph-single: ❌ session already in progress"
      return 1
    fi
  fi

  # Initialize the lock
  ralph-state "$dir" init single

  # Navigate to git root
  local gitRoot="$(git-directory-root)"
  cd "$gitRoot"

  # Launch Claude in foreground; capture exit code
  local claudeExit=0
  claude --permission-mode acceptEdits "/ralph $dir" || claudeExit=$?

  # Always clear the lock, even on failure
  ralph-state "$dir" clear

  return $claudeExit
}
