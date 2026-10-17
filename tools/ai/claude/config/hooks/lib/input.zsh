# Hook input helpers: set up the hook from its stdin JSON, then read or replace keys of it
# Usage:
# $ source lib/input.zsh
# $ hookInit                                    # first call: keeps the JSON, sets the session variables
# $ local command="$(inputKeyRead '.tool_input.command')"

# Set up what the rest of the hook assumes, from the hook JSON on stdin
# Must be the first call of the hook
# Every variable is a shell variable, never exported: the hook functions see them, child processes do not
# (a JSON over 128 KB in the environment would make every child process fail)
# - CLAUDE_HOOK_INPUT: the whole hook JSON
# - CLAUDE_SESSION_ID and CLAUDE_SESSION_DIR: the session and its directory (the directory stays empty without a session id)
# - CLAUDE_CWD and CLAUDE_GIT_ROOT: the working directory of the tool call and its git root
#   CLAUDE_GIT_ROOT stays empty outside a git repo
# Usage:
# $ hookInit  # CLAUDE_SESSION_ID=<.session_id>, CLAUDE_SESSION_DIR=<sessions dir>/<.session_id>
function hookInit() {
  CLAUDE_HOOK_INPUT="$(cat)"
  CLAUDE_SESSION_ID="$(inputKeyRead '.session_id')"
  CLAUDE_SESSION_DIR="$(claude-session-dir "$CLAUDE_SESSION_ID")"

  CLAUDE_CWD="$(inputKeyRead '.cwd')"

  # Outside a git repo, or without a cwd: no git root
  CLAUDE_GIT_ROOT=""
  if [[ "$CLAUDE_CWD" != "" ]] && git-directory-is-repository "$CLAUDE_CWD"; then
    CLAUDE_GIT_ROOT="$(git-directory-root "$CLAUDE_CWD")"
  fi
}

# Read one key of the hook JSON, empty when the key is absent
# Usage:
# $ inputKeyRead '.tool_input.command'  # echo hello
# $ inputKeyRead '.cwd'                 # /home/tim/project
# $ inputKeyRead '.tool_use_id'         # toolu_01abc
# $ inputKeyRead '.agent_id'            # empty outside a subagent
function inputKeyRead() {
  json-get "$1" <<<"$CLAUDE_HOOK_INPUT"
}

# Replace one key of the hook JSON by a string, inputKeyRead then gives the new value
# Changes CLAUDE_HOOK_INPUT, so call it directly, never inside $(...)
# Usage:
# $ inputKeyWrite '.tool_input.command' "rm-guarded a"
# $ inputKeyRead '.tool_input.command'  # rm-guarded a
function inputKeyWrite() {
  CLAUDE_HOOK_INPUT="$(jq \
    --compact-output \
    --arg value "$2" \
    "${1} = \$value" <<<"$CLAUDE_HOOK_INPUT")"
}
