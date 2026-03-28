#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks
# Source this file in your hooks: source /home/tim/.oroshi/config/cli/claudecode/hooks/lib/hookLib.zsh

# ============================================================================
# Stdin Functions
# ============================================================================

# Get a specific value from tool_input
# Usage: getToolInput "file_path" or getToolInput "command" or getToolInput "url"
function getToolInput() {
  local key=$1
  cat | jq -r ".tool_input.${key}"
}

# ============================================================================
# Decision Functions
# ============================================================================

# Accept the tool
function acceptTool() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# Let Claude Code's normal permission system handle it
function letClaudeAsk() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# Ask the user explicitly
function askUser() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# Deny the tool with a reason
function denyTool() {
  local reason=$1
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="deny" \
    hookSpecificOutput.permissionDecisionReason="$reason" \
    hookSpecificOutput.oroshiDebug="$DEBUG_OUTPUT"
  exit 0
}

# ============================================================================
# Debug Functions
# ============================================================================

# Global variable for debug output buffer
DEBUG_OUTPUT=""

# Add debug message to output buffer
# Usage: debug "message"
function debug() {
  DEBUG_OUTPUT="${DEBUG_OUTPUT}${1}\n"
}
