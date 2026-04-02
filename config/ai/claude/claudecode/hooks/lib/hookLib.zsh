#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks

# Save stdin data to a temporary JSON file and return the file path
function saveInputAsJson() {
  local stdinData=$(cat)

  local tmpDir=/tmp/oroshi/claude/hooks
  mkdir -p "$tmpDir"

  # Generate unique filename using process ID
  local filePath="${tmpDir}/input-$$.json"

  # Fix invalid JSON and save to file
  # Handles:
  # - Valid JSON: {"tool_name":"WebFetch"}
  # - Invalid JSON with newlines: {"prompt":"Line 1\nLine 2"}
  # - Invalid escape sequences: {"command":"echo ok\; done"}
  # - Escaped chars: {"command":"echo \"hello\""}
  # - Nested fields: {"tool_input":{"command":"ls"}}
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

# Let Claude Code's normal permission system handle it
# Usage: letClaudeAsk [hint_message]
# If hint_message is provided, it will be shown to the user in the permission dialog
function letClaudeAsk() {
  local hint=$1
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
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
