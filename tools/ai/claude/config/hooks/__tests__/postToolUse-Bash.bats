bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../postToolUse-Bash"
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
  # Module calls run as session "test", like the hook input below
  approvalPrefix="CLAUDE_SESSION_ID=test; source '${BATS_TEST_DIRNAME}/../Bash-approval.zsh'"
}

@test "post event for a pending tool use id increments the count of each of its commands" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget --command curl"
  bats_run_zsh "${approvalPrefix}; approvalCountIncrement --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]

  bats_run_zsh "${approvalPrefix}; approvalCountGet --command wget"
  [[ "$output" = "2" ]]
  bats_run_zsh "${approvalPrefix}; approvalCountGet --command curl"
  [[ "$output" = "1" ]]
}

@test "a command reaching 3 approvals is added to the session allow-list" {
  bats_run_zsh "${approvalPrefix}; approvalCountIncrement --command wget; approvalCountIncrement --command wget"
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget --command telnet"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com && telnet bad.com"}}'
  [[ "$status" -eq 0 ]]

  local allowListFile="$BATS_TMP_DIR/test/allow-list.json"
  [[ "$(jq --compact-output '.' "$allowListFile")" = '["wget"]' ]]
}

@test "a command at 1 or 2 approvals is not added to the session allow-list" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/test/allow-list.json" ]]

  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_02 --command wget"
  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_02","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/test/allow-list.json" ]]

  bats_run_zsh "${approvalPrefix}; approvalCountGet --command wget"
  [[ "$output" = "2" ]]
}

@test "post event removes the approval pending entry of its tool use id" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_02 --command curl"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]

  bats_run_zsh "${approvalPrefix}; approvalPendingGet --tool-use-id toolu_01"
  [[ "$output" = "" ]]
  bats_run_zsh "${approvalPrefix}; approvalPendingGet --tool-use-id toolu_02"
  [[ "$output" = "curl" ]]
}

@test "post event for an unknown tool use id changes nothing" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  local stateFile="$BATS_TMP_DIR/test/state.json"
  local stateBefore="$(cat "$stateFile")"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_unknown","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$stateFile")" = "$stateBefore" ]]
}

@test "post hook prints nothing and exits 0 with session id" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "post hook prints nothing and exits 0 without session id" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ "$(ls --almost-all "$BATS_TMP_DIR")" = "" ]]
}

@test "post hook does not run solkan" {
  solkan() { print called >>"$BATS_TMP_DIR/solkan.log"; }
  bats_mock solkan

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/solkan.log" ]]
}

@test "failure event relays a marker line as additionalContext" {
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\n[claude-guarded:refused] Retry with /bin/rm.')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = "Retry with /bin/rm." ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.hookEventName' <<<"$output")" = "PostToolUseFailure" ]]
}

@test "failure event relays several marker lines" {
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\n[claude-guarded:refused] First.\n[claude-guarded:refused] Second.')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = $'First.\nSecond.' ]]
}

@test "failure event without a marker prints nothing" {
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\nrm: cannot remove: No such file')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "failure event does not relay non-marker lines of the error" {
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\nsome stdout\n[claude-guarded:refused] Retry.\nrm: other failure')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"some stdout"* ]]
  [[ "$output" != *"other failure"* ]]
  [[ "$output" != *"Exit code"* ]]
}

@test "success event relays a marker line from a command that exited 0" {
  local response="$(jo stdout=$'out-line\n[claude-guarded:refused] Retry with /bin/rm.' stderr=)"
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUse tool_name=Bash \
    tool_response="$response")"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = "Retry with /bin/rm." ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.hookEventName' <<<"$output")" = "PostToolUse" ]]
}

@test "success event relays a marker line written to stderr" {
  local response="$(jo stdout= stderr=$'[claude-guarded:refused] Retry with /bin/rm.')"
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUse tool_name=Bash \
    tool_response="$response")"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = "Retry with /bin/rm." ]]
}

@test "relaying a marker still counts approvals of a pending tool use id" {
  bats_run_zsh "${approvalPrefix}; approvalPendingAdd --tool-use-id toolu_01 --command rm"
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\n[claude-guarded:refused] Retry.')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = "Retry." ]]

  bats_run_zsh "${approvalPrefix}; approvalCountGet --command rm"
  [[ "$output" = "1" ]]
}

@test "failure event relays a marker line written without a space after the marker" {
  local input="$(jo session_id=test tool_use_id=toolu_01 hook_event_name=PostToolUseFailure tool_name=Bash \
    error=$'Exit code 1\n[claude-guarded:refused]Retry.')"

  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = "Retry." ]]
}

@test "input that is not JSON exits 0 and prints nothing" {
  bats_run_zsh "$SCRIPT 2>/dev/null" <<<'not json'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
