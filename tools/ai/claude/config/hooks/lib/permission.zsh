# Hook permission: the decision a PreToolUse hook prints on stdout
# - Allow the tool call: autoApprove
# - Ask the user: askWithReason (rejectedCommandsFormat builds the reason text)
# Each decision function prints its JSON and exits, so the hook ends there
# Usage:
# $ source lib/permission.zsh
# $ autoApprove "$toolInputJson"                            # allow, tool input replaced in updatedInput
# $ askWithReason "$(rejectedCommandsFormat wget:1)" "$toolInputJson"

# Allow the tool call, optionally replacing the whole tool input (JSON object)
# Usage:
# $ autoApprove                                   # tool input untouched
# $ autoApprove '{"command":"echo hi","timeout":5000}'
function autoApprove() {
  local -a updatedInput=()
  [[ "$1" != "" ]] && updatedInput=(hookSpecificOutput.updatedInput="$1")

  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    "${updatedInput[@]}"
  exit 0
}

# Ask the user, showing the reason, optionally replacing the whole tool input (JSON object)
# Usage:
# $ askWithReason "❌ wget ❌"
# $ askWithReason "❌ wget ❌" '{"command":"wget foo","timeout":5000}'
function askWithReason() {
  local -a updatedInput=()
  [[ "$2" != "" ]] && updatedInput=(hookSpecificOutput.updatedInput="$2")

  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.permissionDecisionReason="$1" \
    "${updatedInput[@]}"
  exit 0
}

# Format the rejected commands as the reason of an ask: a moon for each approval count, all between ❌
# Each argument is command:count, split on the last colon. Without a count, it is 0
# Count 0: no symbol, 1: 🌓, 2 or more: 🌕
# Usage:
# $ rejectedCommandsFormat /usr/bin/grep:2 wget:0
# ❌ /usr/bin/grep 🌕, wget ❌
function rejectedCommandsFormat() {
  local -a entries=()
  local item
  for item in "$@"; do
    local command="${item%:*}"
    local count="${item##*:}"

    # No numeric count after a colon: the whole argument is the command
    if [[ ! "$count" =~ ^[0-9]+$ ]]; then
      command="$item"
      count=0
    fi

    local moon=""
    [[ "$count" -ge 1 ]] && moon=" 🌓"
    [[ "$count" -ge 2 ]] && moon=" 🌕"
    entries+=("${command}${moon}")
  done

  print -r -- "❌ ${(j:, :)entries} ❌"
}
