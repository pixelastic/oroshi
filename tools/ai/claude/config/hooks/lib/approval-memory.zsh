# Approval memory: count the user's approvals, promote often-approved commands to the session allow-list
# - approval request: commands awaiting the user's answer, keyed by tool use id
# - approval count: how many times the user approved each command
# - session allow-list: commands Solkan allows for the rest of the session
# Shared by preToolUse-Bash and postToolUse-Bash
# Needs hookInit (lib/input.zsh) to have run: it sets CLAUDE_SESSION_ID and CLAUDE_SESSION_DIR
#
# State lives in $CLAUDE_SESSION_DIR/state.json
# Session allow-list lives in $CLAUDE_SESSION_DIR/allow-list.json
# Every public function is a no-op when CLAUDE_SESSION_ID is empty
# Usage:
# $ source lib/approval-memory.zsh
# $ approvalRequestOpen --tool-use-id toolu_01 --command wget   # record what the user is asked
# $ approvalCountGet --command wget                            # 0
# $ approvalRequestClose --tool-use-id toolu_01                # the user answered: count, promote, forget
# $ approvalCountIncrement --command wget                      # 1
# $ sessionAllowListAdd --command wget                         # Solkan allows wget from now on

# Approvals after which a command joins the session allow-list
SESSION_ALLOW_LIST_THRESHOLD=3

# Open an approval request: record the rejected commands the user is asked to approve for a tool use
# Closed by approvalRequestClose in postToolUse-Bash
# Usage:
# $ approvalRequestOpen --tool-use-id toolu_01 --command wget --command curl
function approvalRequestOpen() {
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
    '.preToolUse.Bash.approvalRequest += [{toolUseId: $toolUseId, commands: $ARGS.positional}]' \
    --args "${commands[@]}" \
    | approvalStateWrite
}

# Close the approval request of a tool use: the user said yes to each of its commands
# Counts each approval, adds the often-approved commands to the session allow-list, forgets the request
# Opened by approvalRequestOpen in preToolUse-Bash
# Usage:
# $ approvalRequestClose --tool-use-id toolu_01
function approvalRequestClose() {
  # No session: nothing tracked
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -tool-use-id:=flagToolUseId

  local toolUseId="${flagToolUseId[2]}"

  # No tool use id: never matches an approval request
  [[ "$toolUseId" == "" ]] && return 0

  # Each command of this request was approved by the user
  local approvedCommandsRaw="$(
    approvalStateRead \
      | jq \
      --raw-output \
      --arg toolUseId "$toolUseId" \
      '.preToolUse.Bash.approvalRequest[]? | select(.toolUseId == $toolUseId) | .commands[]'
  )"
  local -a approvedCommands=(${(@f)approvedCommandsRaw})

  # No request (auto-approved or unknown tool use): leave state untouched
  [[ "${#approvedCommands}" -eq 0 ]] && return 0

  local approvedCommand
  for approvedCommand in $approvedCommands; do
    local approvalCount="$(approvalCountIncrement --command "$approvedCommand")"

    # Approved often enough: stop asking for the rest of the session
    [[ "$approvalCount" -ge "$SESSION_ALLOW_LIST_THRESHOLD" ]] && sessionAllowListAdd --command "$approvedCommand"
  done

  # User answered: this request is closed
  approvalStateRead \
    | jq \
    --arg toolUseId "$toolUseId" \
    '.preToolUse.Bash.approvalRequest |= map(select(.toolUseId != $toolUseId))' \
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

# Add a command to the session allow-list, so Solkan allows it for the rest of the session
# Usage:
# $ sessionAllowListAdd --command wget
function sessionAllowListAdd() {
  # No session: nothing to allow
  [[ "$CLAUDE_SESSION_ID" == "" ]] && return 0

  zparseopts -E -D \
    -command:=flagCommand

  local command="${flagCommand[2]}"

  # No command: nothing to allow
  [[ "$command" == "" ]] && return 0

  json-array-add --input "${CLAUDE_SESSION_DIR}/allow-list.json" --unique "$command"
}

# Print the session state JSON, or an empty object when absent
function approvalStateRead() {
  local stateFile="${CLAUDE_SESSION_DIR}/state.json"

  # No state yet: start from scratch
  if [[ ! -f "$stateFile" ]]; then
    print '{}'
    return 0
  fi

  cat -- "$stateFile"
}

# Replace the session state JSON with stdin
function approvalStateWrite() {
  local stateFile="${CLAUDE_SESSION_DIR}/state.json"
  local newJson="$(cat -)"

  # jq failed upstream: keep existing state untouched
  [[ "$newJson" == "" ]] && return 1

  mkdir -p "${stateFile:h}"
  print -r -- "$newJson" >"$stateFile"
}
