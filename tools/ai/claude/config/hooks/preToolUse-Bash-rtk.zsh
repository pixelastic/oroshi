# Defines preToolUse-Bash-rtk() for use by preToolUse-Bash
# Sourced by the hook
# Not standalone — no shebang, not chmod +x
#
# Usage (called by the hook):
# $ preToolUse-Bash-rtk "git status"   # → "rtk git status" (rewritten)
# $ preToolUse-Bash-rtk "echo hello"   # → "echo hello" (passthrough)

# Guard: skip if already defined (e.g. mocked in tests)
whence preToolUse-Bash-rtk > /dev/null && return 0

preToolUse-Bash-rtk() {
  local cmd="$1"

  # Already rewritten — pass through unchanged
  if [[ "${cmd%% *}" == "rtk" ]]; then
    print -- "$cmd"
    return 0
  fi

  # rtk rewrite: stdout = rewritten command, empty = no equivalent
  local rewritten="$(rtk rewrite "$cmd")"
  if [[ "$rewritten" == "" ]]; then
    print -- "$cmd"
    return 0
  fi

  print -- "$rewritten"
}
