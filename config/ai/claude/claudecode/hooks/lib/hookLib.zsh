#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks
# Source this file in your hooks: source /home/tim/.oroshi/config/ai/claude/claudecode/hooks/lib/hookLib.zsh

# Save stdin data to a temporary JSON file and return the file path
#
# Creates a file in $OROSHI_TMP_FOLDER/claude/hooks/ with a unique name
# based on the process ID ($$). The function handles invalid JSON by:
# - Escaping literal newlines as \n
# - Fixing invalid escape sequences like \; by doubling the backslash
#
# Usage:
#   filePath=$(saveInputAsJson)
#
# Returns: Full path to the saved JSON file
function saveInputAsJson() {
  local stdinData=$(cat)

  # Create the hooks directory if it doesn't exist
  local hooksDir="${OROSHI_TMP_FOLDER}/claude/hooks"
  mkdir -p "$hooksDir"

  # Generate unique filename using process ID
  local filePath="${hooksDir}/input-$$.json"

  # Fix invalid JSON and save to file
  printf '%s' "$stdinData" \
    | sed 's/\\;/\\\\;/g' \
    | sed -z 's/\n/\\n/g' \
    | sed 's/\\n$//' \
    > "$filePath"

  echo "$filePath"
}

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
#   getField "tool_name" "$filePath"
#   getField "tool_input.command" "$filePath"
function getField() {
  local field=$1
  local filePath=$2

  # Read the JSON file (already sanitized by saveInputAsJson)
  cat "$filePath" | jq -r ".${field} // empty"
}

# Get a specific value from tool_input
# Usage: getToolInput "file_path" "$filePath"
#        getToolInput "command" "$filePath"
function getToolInput() {
  local key=$1
  local filePath=$2
  getField "tool_input.${key}" "$filePath"
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
