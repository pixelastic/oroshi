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
  local base="$(cat "$stateFile" 2>/dev/null)"
  [[ "$base" == "" ]] && base="{}"
  local -a askedCommands=(${(@f)$(print -r -- "$base" | jq -r '.preToolUse.Bash.askedCommands[]' 2>/dev/null)})
  # Add the new ones
  askedCommands+=("$@")
  # Sort and uniq
  askedCommands=("${(@ou)askedCommands}")
  # Write it back
  print -r -- "$base" | jq --args '.preToolUse.Bash.askedCommands = $ARGS.positional' "${askedCommands[@]}" >"$stateFile"
}
