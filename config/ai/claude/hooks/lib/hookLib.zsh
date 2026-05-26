#!/usr/bin/env zsh
# Common functions for Claude Code preToolUse hooks

# Log directory configuration
CLAUDE_HOOKS_LOG_DIR="/tmp/oroshi/claude/hooks"

# Accept the tool
function autoApprove() {
  zparseopts -D -E -- \
    -updatedInput:=updatedInputFlag
  local updatedInputCommand=${updatedInputFlag[2]}

  local joArgs=(
    hookSpecificOutput.hookEventName="PreToolUse"
    hookSpecificOutput.permissionDecision="allow"
  )
  if [[ "$updatedInputCommand" != "" ]]; then
    joArgs+=(hookSpecificOutput.updatedInput.command="${updatedInputCommand}")
  fi

  jo -d. "${joArgs[@]}"
  exit 0
}

# Let Claude Code's default permission system decide
function askUser() {
  zparseopts -D -E -- \
    -updatedInput:=updatedInputFlag
  local updatedInputCommand=${updatedInputFlag[2]}

  local joArgs=(
    hookSpecificOutput.hookEventName="PreToolUse"
    hookSpecificOutput.permissionDecision="ask"
    hookSpecificOutput.permissionDecisionReason="❌ Not part of allowlist.json"
  )
  if [[ "$updatedInputCommand" != "" ]]; then
    joArgs+=(hookSpecificOutput.updatedInput.command="${updatedInputCommand}")
  fi

  jo -d. "${joArgs[@]}"
  exit 0
}
