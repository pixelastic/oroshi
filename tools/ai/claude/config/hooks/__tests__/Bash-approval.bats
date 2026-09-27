bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
  export CLAUDE_SESSION_ID="test"
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../Bash-approval.zsh'"
}

# approvalPendingAdd / approvalPendingGet

@test "approvalPendingAdd stores the commands under the tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget --command /usr/bin/grep"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  local stateFile="$BATS_TMP_DIR/test/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending' "$stateFile")" = '[{"toolUseId":"toolu_01","commands":["wget","/usr/bin/grep"]}]' ]]
}

@test "approvalPendingAdd appends to existing entries" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_02 --command curl"

  local stateFile="$BATS_TMP_DIR/test/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending | map(.toolUseId)' "$stateFile")" = '["toolu_01","toolu_02"]' ]]
}

@test "approvalPendingGet prints the stored commands one per line" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget --command /usr/bin/grep"
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_02 --command curl"

  bats_run_zsh "${sourcePrefix}; approvalPendingGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'wget\n/usr/bin/grep' ]]
}

@test "approvalPendingGet prints nothing for an unknown tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"

  bats_run_zsh "${sourcePrefix}; approvalPendingGet --tool-use-id toolu_unknown"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "approvalPendingGet prints nothing when no state file exists" {
  bats_run_zsh "${sourcePrefix}; approvalPendingGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# approvalPendingRemove

@test "approvalPendingRemove removes only the entry of that tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_02 --command curl"

  bats_run_zsh "${sourcePrefix}; approvalPendingRemove --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  local stateFile="$BATS_TMP_DIR/test/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending' "$stateFile")" = '[{"toolUseId":"toolu_02","commands":["curl"]}]' ]]
}

@test "approvalPendingRemove with an empty tool use id changes nothing" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  local stateFile="$BATS_TMP_DIR/test/state.json"
  local stateBefore="$(cat "$stateFile")"

  bats_run_zsh "${sourcePrefix}; approvalPendingRemove --tool-use-id ''"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$stateFile")" = "$stateBefore" ]]
}

# approvalCountGet / approvalCountIncrement

@test "approvalCountGet prints 0 for an unknown command" {
  bats_run_zsh "${sourcePrefix}; approvalCountGet --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "0" ]]
}

@test "approvalCountIncrement increments from 0 to 1, then 2, and prints the new count" {
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "1" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "2" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountGet --command /usr/bin/grep"
  [[ "$output" = "2" ]]

  local stateFile="$BATS_TMP_DIR/test/state.json"
  [[ "$(jq --compact-output '.postToolUse.Bash.approvalCount' "$stateFile")" = '{"/usr/bin/grep":2}' ]]
}

@test "approvalCountIncrement keeps counts of other commands" {
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command curl"

  bats_run_zsh "${sourcePrefix}; approvalCountGet --command wget"
  [[ "$output" = "1" ]]
}

# Empty arguments

@test "empty tool use id is neither stored nor matched" {
  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id '' --command wget"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/test/state.json" ]]

  bats_run_zsh "${sourcePrefix}; approvalPendingGet --tool-use-id ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "empty command is neither counted nor stored" {
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -e "$BATS_TMP_DIR/test/state.json" ]]
}

# No session id

@test "every function is a no-op when CLAUDE_SESSION_ID is empty" {
  export CLAUDE_SESSION_ID=""

  bats_run_zsh "${sourcePrefix}; approvalPendingAdd --tool-use-id toolu_01 --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalPendingGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalPendingRemove --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountGet --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  [[ "$(ls --almost-all "$BATS_TMP_DIR")" = "" ]]
}
