#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks
# Source this file in your hooks: source /home/tim/.oroshi/config/cli/claudecode/hooks/lib/hookLib.zsh

# Parse the stdin data from Claude Code and extract a field value
#
# Handles:
# - Valid JSON: {"tool_name":"WebFetch"}
# - Invalid JSON with newlines: {"prompt":"Line 1\nLine 2"}
# - Escaped chars: {"command":"echo \"hello\""}
# - Nested fields: {"tool_input":{"command":"ls"}}
#
# Usage:
#   getField "tool_name" <<< "$stdinData"
#   getField "tool_input.command" <<< "$stdinData"
function getField() {
  local field=$1
  local stdinData=$(cat)

  # Try standard jq parsing first (works for valid JSON)
  local value=$(printf '%s' "$stdinData" | jq -r ".${field}" 2>/dev/null)

  # If jq worked and returned a non-empty value, use it
  if [[ -n "$value" && "$value" != "null" ]]; then
    printf '%s' "$value"
    return 0
  fi

  # Fallback: use perl regex (handles invalid JSON with newlines)
  # For nested fields like "tool_input.command", extract just the last part
  local fieldName="${field##*.}"

  # This extracts "fieldName":"value" or "fieldName": "value" patterns
  # It captures everything between the quotes, including newlines
  value=$(printf '%s' "$stdinData" | perl -0777 -ne "print \$1 if /\"${fieldName}\"\\s*:\\s*\"((?:[^\"]|\\\\\")*)\"/" | perl -pe 's/\\n/\n/g; s/\\"/"/g')

  printf '%s' "$value"
}

# Get a specific value from tool_input
# Usage: getToolInput "file_path" <<< "$stdinData"
#        getToolInput "command" <<< "$stdinData"
function getToolInput() {
  local key=$1
  getField "tool_input.${key}"
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
