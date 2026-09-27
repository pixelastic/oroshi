# Session state for Bash approvals, shared by preToolUse-Bash and postToolUse-Bash
# - approval pending: commands awaiting the user's answer, keyed by tool use id
# - approval count: how many times the user approved each command
# Sourced by the hooks
#
# State lives in $CLAUDE_SESSIONS_DIR/$CLAUDE_SESSION_ID/state.json
# Every function is a no-op when CLAUDE_SESSION_ID is empty

# Record the rejected commands the user is asked to approve for a tool use
# Usage:
# $ approvalPendingAdd --tool-use-id toolu_01 --command wget --command curl
function approvalPendingAdd() {
  # No session: nothing to track
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -tool-use-id:=flagToolUseId \
    -command+:=flagCommands

  local toolUseId="${flagToolUseId[2]}"
  local -a commands=(${flagCommands:#--command})

  # No tool use id: could never be matched by a post event
  [[ "$toolUseId" == "" ]] && return 0

  approvalStateRead \
    | jq \
    --arg toolUseId "$toolUseId" \
    '.preToolUse.Bash.approvalPending += [{toolUseId: $toolUseId, commands: $ARGS.positional}]' \
    --args "${commands[@]}" \
    | approvalStateWrite
}

# Print the pending commands of a tool use, one per line (nothing if unknown)
# Usage:
# $ approvalPendingGet --tool-use-id toolu_01  # wget\ncurl
function approvalPendingGet() {
  # No session: nothing tracked
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -tool-use-id:=flagToolUseId

  local toolUseId="${flagToolUseId[2]}"

  # No tool use id: never matches a pending entry
  [[ "$toolUseId" == "" ]] && return 0

  approvalStateRead \
    | jq \
    --raw-output \
    --arg toolUseId "$toolUseId" \
    '.preToolUse.Bash.approvalPending[]? | select(.toolUseId == $toolUseId) | .commands[]'
}

# Forget the pending commands of a tool use, once the user has answered
# Usage:
# $ approvalPendingRemove --tool-use-id toolu_01
function approvalPendingRemove() {
  # No session: nothing tracked
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -tool-use-id:=flagToolUseId

  local toolUseId="${flagToolUseId[2]}"

  # No tool use id: never matches a pending entry
  [[ "$toolUseId" == "" ]] && return 0

  approvalStateRead \
    | jq \
    --arg toolUseId "$toolUseId" \
    '.preToolUse.Bash.approvalPending |= map(select(.toolUseId != $toolUseId))' \
    | approvalStateWrite
}

# Print how many times the user approved a command (0 if never)
# Usage:
# $ approvalCountGet --command wget  # 0
function approvalCountGet() {
  # No session: nothing tracked
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -command:=flagCommand

  local command="${flagCommand[2]}"

  approvalStateRead \
    | jq \
    --raw-output \
    --arg command "$command" \
    '.postToolUse.Bash.approvalCount[$command] // 0'
}

# Add one approval to a command and print the new count
# Usage:
# $ approvalCountIncrement --command wget  # 1
function approvalCountIncrement() {
  # No session: nothing to track
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -command:=flagCommand

  local command="${flagCommand[2]}"

  # No command: nothing to count
  [[ "$command" == "" ]] && return 0

  local newCount=$(($(approvalCountGet --command "$command") + 1))

  approvalStateRead \
    | jq \
    --arg command "$command" \
    --argjson count "$newCount" \
    '.postToolUse.Bash.approvalCount[$command] = $count' \
    | approvalStateWrite

  print -r -- "$newCount"
}

# Path of the current session state file
function approvalStateFile() {
  local sessionsDir="${CLAUDE_SESSIONS_DIR:-/tmp/oroshi/claude/sessions}"
  print -r -- "${sessionsDir}/${CLAUDE_SESSION_ID}/state.json"
}

# Print the session state JSON, or an empty object when absent
function approvalStateRead() {
  local stateFile="$(approvalStateFile)"

  # No state yet: start from scratch
  if [[ ! -f "$stateFile" ]]; then
    print '{}'
    return 0
  fi

  cat -- "$stateFile"
}

# Replace the session state JSON with stdin
function approvalStateWrite() {
  local stateFile="$(approvalStateFile)"
  local newJson="$(cat -)"

  # jq failed upstream: keep existing state untouched
  [[ "$newJson" == "" ]] && return 1

  mkdir -p "${stateFile:h}"
  print -r -- "$newJson" >"$stateFile"
}
