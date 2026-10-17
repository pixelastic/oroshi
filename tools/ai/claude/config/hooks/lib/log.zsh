# Hook debug log: save a pretty-printed copy of the hook input, named after the calling hook
# Needs hookInit (lib/input.zsh) to have run: it logs CLAUDE_HOOK_INPUT
# Usage:
# $ source lib/log.zsh
# $ logInput bash     # writes ${OROSHI_FOLDER_CACHE}/claude/hooks/last-bash-input.json
# $ logInput monitor  # writes ${OROSHI_FOLDER_CACHE}/claude/hooks/last-monitor-input.json

# Save the hook input for debugging, creates the log directory first
# Usage:
# $ logInput bash     # last-bash-input.json
# $ logInput monitor  # last-monitor-input.json
function logInput() {
  local name="$1"
  local logDir="${OROSHI_FOLDER_CACHE}/claude/hooks"

  mkdir -p "$logDir"
  jq '.' <<<"$CLAUDE_HOOK_INPUT" >"${logDir}/last-${name}-input.json"
}
