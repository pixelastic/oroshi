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
    hookSpecificOutput.permissionDecisionReason="$1" \
    hookSpecificOutput.updatedInput.command="$2"
  exit 0
}

# Build the ask reason: each rejected command with a moon for its approval count
# Count 0: no symbol, 1: 🌓, 2 or more: 🌕
# --command and --count are paired by position
# Usage:
# $ askReasonFormat --command /usr/bin/grep --count 2 --command wget --count 0
# ❌ /usr/bin/grep 🌕, wget ❌
function askReasonFormat() {
  zparseopts -E -D \
    -command+:=flagCommands \
    -count+:=flagCounts

  local -a commands=(${flagCommands:#--command})
  local -a counts=(${flagCounts:#--count})

  local -a entries=()
  local index
  for ((index = 1; index <= ${#commands}; index++)); do
    local count="${counts[$index]:-0}"
    local moon=""
    [[ "$count" -ge 1 ]] && moon=" 🌓"
    [[ "$count" -ge 2 ]] && moon=" 🌕"
    entries+=("${commands[$index]}${moon}")
  done

  print -r -- "❌ ${(j:, :)entries} ❌"
}
