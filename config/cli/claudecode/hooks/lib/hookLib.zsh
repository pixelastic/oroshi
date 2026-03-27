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

# Accept the tool with optional debug output
function acceptTool() {
  local debugOutput=$1
  if [[ -n "$debugOutput" ]]; then
    jo -d. \
      hookSpecificOutput.hookEventName="PreToolUse" \
      hookSpecificOutput.permissionDecision="allow" \
      hookSpecificOutput.oroshiDebug="$debugOutput"
  else
    jo -d. \
      hookSpecificOutput.hookEventName="PreToolUse" \
      hookSpecificOutput.permissionDecision="allow"
  fi
  exit 0
}

# Let Claude Code's normal permission system handle it
function letClaudeAsk() {
  local debugOutput=$1
  if [[ -n "$debugOutput" ]]; then
    jo -d. \
      hookSpecificOutput.hookEventName="PreToolUse" \
      hookSpecificOutput.oroshiDebug="$debugOutput"
  fi
  exit 0
}

# Ask the user explicitly
function askUser() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask"
  exit 0
}

# Deny the tool with a reason
function denyTool() {
  local reason=$1
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="deny" \
    hookSpecificOutput.permissionDecisionReason="$reason"
  exit 0
}

# ============================================================================
# Debug Functions
# ============================================================================

# Global variable for debug output buffer
DEBUG_OUTPUT=""

# Add debug message to output buffer (only if CLAUDE_HOOK_DEBUG is set)
# Usage: debug "message"
function debug() {
  [[ -z "$CLAUDE_HOOK_DEBUG" ]] && return
  DEBUG_OUTPUT="${DEBUG_OUTPUT}${1}\n"
}

# Common debug separator
function debugSeparator() {
  debug "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Get buffered debug output (for passing to acceptTool/letClaudeAsk)
# Returns empty string if debug is disabled
function getDebugOutput() {
  [[ -z "$CLAUDE_HOOK_DEBUG" ]] && return
  echo "$DEBUG_OUTPUT"
}
