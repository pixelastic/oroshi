#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks

# Log directory configuration
CLAUDE_HOOKS_LOG_DIR="/tmp/oroshi/claude/hooks"

# Save stdin data to a temporary JSON file and return the file path
#
# Tries to save valid JSON as-is, or attempts to fix invalid JSON with literal newlines
function saveInputAsJson() {
  local stdinData=$(cat)

  # Generate unique filename using process ID
  local filePath="${CLAUDE_HOOKS_LOG_DIR}/input-$$.json"

  # Try to parse as-is first (Claude usually sends valid JSON)
  if printf '%s' "$stdinData" | jq empty 2>/dev/null; then
    printf '%s' "$stdinData" >"$filePath"
    echo "$filePath"
    return 0
  fi

  # Invalid JSON - try to fix literal newlines and escape sequences
  printf '%s' "$stdinData" |
    sed 's/\\;/\\\\;/g' |
    sed -z 's/\n/\\n/g' |
    sed 's/\\n$//' \
      >"$filePath"

  echo "$filePath"
}

# Accept the tool
function acceptTool() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# Let Claude Code's default permission system decide
# Usage: letClaudeDecide [hint_message]
function letClaudeDecide() {
  local hint=$1
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecisionReason="$hint" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# Add debug message to output buffer
# Usage: debug "message"
DEBUG_OUTPUT=""
function debug() {
  DEBUG_OUTPUT="${DEBUG_OUTPUT}${1}\n"
}
