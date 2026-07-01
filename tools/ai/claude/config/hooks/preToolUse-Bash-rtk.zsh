# Defines preToolUse-Bash-rtk() for use by preToolUse-Bash
# Sourced by the hook
#
# Usage (called by the hook):
# $ preToolUse-Bash-rtk "git status"   # → "rtk git status" (rewritten)
# $ preToolUse-Bash-rtk "echo hello"   # → "echo hello" (ignored)

# Guard: skip if already defined (e.g. mocked in tests)
whence preToolUse-Bash-rtk >/dev/null && return 0

preToolUse-Bash-rtk() {
  local cmd="$1"

  # Already rewritten — pass through unchanged
  if [[ $cmd == rtk\ * ]]; then
    print -r -- "$cmd"
    return 0
  fi

  # Delegate rewrite decision to rtk-can-rewrite
  if ! rtk-can-rewrite "$cmd"; then
    print -r -- "$cmd"
    return 0
  fi

  print -r -- "rtk $cmd"
}
