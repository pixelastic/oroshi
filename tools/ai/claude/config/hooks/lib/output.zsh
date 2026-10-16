# Hook output: emit the JSON responses a hook prints on stdout
# Stateless: it never reads approval counts, the calling hook passes them in
# autoApprove, autoApproveAsIs, autoApproveToolInput, askWithReason, askWithReasonToolInput and additionalContext print one hookSpecificOutput JSON and exit 0, so the hook ends there
# Usage:
# $ source lib/output.zsh
# $ autoApprove "$command"                                  # allow, command in updatedInput
# $ autoApproveToolInput "$toolInputJson"                   # allow, whole tool input in updatedInput
# $ autoApproveAsIs                                         # allow, no updatedInput
# $ askWithReason "$(askReasonFormat --command wget --count 1)" "$command"
# $ additionalContext PostToolUse "context for Claude"      # also PostToolUseFailure

# Allow the tool call, the command goes back in updatedInput
# Usage:
# $ autoApprove "echo hello"
function autoApprove() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.updatedInput.command="$1"
  exit 0
}

# Allow the tool call, nothing to rewrite
# Usage:
# $ autoApproveAsIs
function autoApproveAsIs() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow"
  exit 0
}

# Ask the user, showing the reason, the command goes back in updatedInput
# Usage:
# $ askWithReason "❌ wget ❌" "wget foo"
function askWithReason() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.permissionDecisionReason="$1" \
    hookSpecificOutput.updatedInput.command="$2"
  exit 0
}

# Allow the tool call, the whole tool input goes back in updatedInput (JSON object)
# Usage:
# $ autoApproveToolInput '{"command":"echo hello","description":"Say hi"}'
function autoApproveToolInput() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="allow" \
    hookSpecificOutput.updatedInput="$1"
  exit 0
}

# Ask the user, showing the reason, the whole tool input goes back in updatedInput (JSON object)
# Usage:
# $ askWithReasonToolInput "❌ wget ❌" '{"command":"wget foo","description":"Fetch"}'
function askWithReasonToolInput() {
  jo -d. \
    hookSpecificOutput.hookEventName="PreToolUse" \
    hookSpecificOutput.permissionDecision="ask" \
    hookSpecificOutput.permissionDecisionReason="$1" \
    hookSpecificOutput.updatedInput="$2"
  exit 0
}

# Build the ask reason: each rejected command with a moon for its approval count
# Count 0: no symbol, 1: 🌓, 2 or more: 🌕
# --command and --count are paired by position
# Usage:
# $ askReasonFormat --command /usr/bin/grep --count 2 --command wget --count 0
# ❌ /usr/bin/grep 🌕, wget ❌
function askReasonFormat() {
  local -a flagCommands
  local -a flagCounts
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

# Give Claude extra context after a tool call, for the given hook event name
# Usage:
# $ additionalContext PostToolUse "context for Claude"
# $ additionalContext PostToolUseFailure "context for Claude"
function additionalContext() {
  jo -d. \
    hookSpecificOutput.hookEventName="$1" \
    hookSpecificOutput.additionalContext="$2"
  exit 0
}
