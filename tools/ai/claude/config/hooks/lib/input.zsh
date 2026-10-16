# Hook input helpers: read the hook JSON from stdin, extract fields, export the session id
# Usage:
# $ source lib/input.zsh
# $ local inputJson="$(inputRead)"                              # whole hook JSON
# $ local command="$(inputField "$inputJson" '.tool_input.command')"
# $ inputSessionExport "$inputJson"                             # sets CLAUDE_SESSION_ID

# Read the whole hook JSON from stdin
# Usage:
# $ inputJson="$(inputRead)"
function inputRead() {
  cat
}

# Extract one field from the hook JSON, empty when the field is absent
# Usage:
# $ inputField "$inputJson" '.tool_input.command'  # echo hello
# $ inputField "$inputJson" '.cwd'                 # /home/tim/project
# $ inputField "$inputJson" '.tool_use_id'         # toolu_01abc
# $ inputField "$inputJson" '.agent_id'            # empty outside a subagent
function inputField() {
  json-get "$2" <<<"$1"
}

# Export the session id, which scopes approval state
# Must run before sourcing approval-memory.zsh
# Usage:
# $ inputSessionExport "$inputJson"  # CLAUDE_SESSION_ID=<.session_id>
function inputSessionExport() {
  export CLAUDE_SESSION_ID="$(inputField "$1" '.session_id')"
}
