# Hook output helpers and session state for preToolUse-Bash

autoApprove() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.updatedInput.command="$1"
  exit 0
}

askWithReason() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.permissionDecisionReason="❌ $1 ❌" \
    hookSpecificOutput.updatedInput.command="$2"
  exit 0
}

askWithAutoAccept() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="defer" \
    hookSpecificOutput.updatedInput.command="$1"
  exit 0
}

markAsAsked() {
  local stateFile="$1"
  shift

  mkdir -p "${stateFile:h}"
  # Get existing askedCommands
  local -a askedCommands=()
  [[ -f "$stateFile" ]] && askedCommands=(${(@f)$(json-get --input "$stateFile" '.preToolUse.Bash.askedCommands')})
  # Add the new ones
  askedCommands+=("$@")
  # Sort and uniq
  askedCommands=("${(@ou)askedCommands}")
  # Write it back
  printf '%s\n' "${askedCommands[@]}" | json-set --input "$stateFile" '.preToolUse.Bash.askedCommands' --array
}
