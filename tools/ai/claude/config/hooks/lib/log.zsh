# Hook debug log: save a pretty-printed copy of the hook input, named after the calling hook
# Env overrides for testing:
#   CLAUDE_HOOKS_LOG_DIR  — defaults to /tmp/oroshi/claude/hooks
# Usage:
# $ source lib/log.zsh
# $ logInput bash "$inputJson"     # writes ${CLAUDE_HOOKS_LOG_DIR}/last-bash-input.json
# $ logInput monitor "$inputJson"  # writes ${CLAUDE_HOOKS_LOG_DIR}/last-monitor-input.json

# Save the hook input for debugging, creates the log directory first
# Usage:
# $ logInput bash "$inputJson"     # last-bash-input.json
# $ logInput monitor "$inputJson"  # last-monitor-input.json
function logInput() {
  local name="$1"
  local inputJson="$2"
  local logDir="${CLAUDE_HOOKS_LOG_DIR:-/tmp/oroshi/claude/hooks}"

  mkdir -p "$logDir"
  jq '.' <<<"$inputJson" >"${logDir}/last-${name}-input.json"
}
