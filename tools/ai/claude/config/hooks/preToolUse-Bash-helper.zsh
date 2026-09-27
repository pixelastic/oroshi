# Hook output helpers for preToolUse-Bash

function autoApprove() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.updatedInput.command="$1"
  exit 0
}

function askWithReason() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.permissionDecisionReason="❌ $1 ❌" \
    hookSpecificOutput.updatedInput.command="$2"
  exit 0
}
