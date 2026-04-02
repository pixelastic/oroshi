#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks
# Source this file in your hooks: source /home/tim/.oroshi/config/cli/claudecode/hooks/lib/hookLib.zsh

# Get a specific value from tool_input
# Usage: getToolInput "file_path" or getToolInput "command" or getToolInput "url"
function getToolInput() {
  local key=$1
  cat | jq -r ".tool_input.${key}"
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
