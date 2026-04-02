#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks
# Source this file in your hooks: source /home/tim/.oroshi/config/ai/claude/claudecode/hooks/lib/hookLib.zsh

# Parse the stdin data from Claude Code and extract a field value
#
# Handles:
# - Valid JSON: {"tool_name":"WebFetch"}
# - Invalid JSON with newlines: {"prompt":"Line 1\nLine 2"}
# - Invalid escape sequences: {"command":"echo ok\; done"}
# - Escaped chars: {"command":"echo \"hello\""}
# - Nested fields: {"tool_input":{"command":"ls"}}
#
# Usage:
#   getField "tool_name" <<< "$stdinData"
#   getField "tool_input.command" <<< "$stdinData"
function getField() {
  local field=$1
  local stdinData=$(cat)

  # Claude Code sometimes sends invalid JSON:
  # - Literal newlines in strings → escape them as \n
  # - Invalid escape sequences like \; → double the backslash
  printf '%s' "$stdinData" \
    | sed 's/\\;/\\\\;/g' \
    | sed -z 's/\n/\\n/g' \
    | sed 's/\\n$//' \
    | jq -r ".${field} // empty"
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
