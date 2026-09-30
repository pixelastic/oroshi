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
