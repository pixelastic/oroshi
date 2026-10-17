bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_SESSION_DIR="$BATS_TMP_DIR/session"
  export CLAUDE_SESSION_ID="test"
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/approval-memory.zsh'"
}

# approvalRequestOpen / approvalRequestGet

@test "approvalRequestOpen stores the commands under the tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget --command /usr/bin/grep"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  local stateFile="$BATS_TMP_DIR/session/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending' "$stateFile")" = '[{"toolUseId":"toolu_01","commands":["wget","/usr/bin/grep"]}]' ]]
}

@test "approvalRequestOpen appends to existing entries" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget"
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_02 --command curl"

  local stateFile="$BATS_TMP_DIR/session/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending | map(.toolUseId)' "$stateFile")" = '["toolu_01","toolu_02"]' ]]
}

@test "approvalRequestGet prints the stored commands one per line" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget --command /usr/bin/grep"
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_02 --command curl"

  bats_run_zsh "${sourcePrefix}; approvalRequestGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'wget\n/usr/bin/grep' ]]
}

@test "approvalRequestGet prints nothing for an unknown tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget"

  bats_run_zsh "${sourcePrefix}; approvalRequestGet --tool-use-id toolu_unknown"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "approvalRequestGet prints nothing when no state file exists" {
  bats_run_zsh "${sourcePrefix}; approvalRequestGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

# approvalRequestClose

@test "approvalRequestClose removes only the entry of that tool use id" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget"
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_02 --command curl"

  bats_run_zsh "${sourcePrefix}; approvalRequestClose --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  local stateFile="$BATS_TMP_DIR/session/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalPending' "$stateFile")" = '[{"toolUseId":"toolu_02","commands":["curl"]}]' ]]
}

@test "approvalRequestClose with an empty tool use id changes nothing" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget"
  local stateFile="$BATS_TMP_DIR/session/state.json"
  local stateBefore="$(cat "$stateFile")"

  bats_run_zsh "${sourcePrefix}; approvalRequestClose --tool-use-id ''"
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

  local stateFile="$BATS_TMP_DIR/session/state.json"
  [[ "$(jq --compact-output '.postToolUse.Bash.approvalCount' "$stateFile")" = '{"/usr/bin/grep":2}' ]]
}

@test "approvalCountIncrement keeps counts of other commands" {
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command curl"

  bats_run_zsh "${sourcePrefix}; approvalCountGet --command wget"
  [[ "$output" = "1" ]]
}

# sessionAllowListAdd

@test "sessionAllowListAdd creates the file with the command" {
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command /usr/bin/grep"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  local allowListFile="$BATS_TMP_DIR/session/allow-list.json"
  [[ "$(jq --compact-output '.' "$allowListFile")" = '["/usr/bin/grep"]' ]]
}

@test "sessionAllowListAdd appends a new command" {
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command wget"
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command telnet"

  local allowListFile="$BATS_TMP_DIR/session/allow-list.json"
  [[ "$(jq --compact-output '.' "$allowListFile")" = '["telnet","wget"]' ]]
}

@test "sessionAllowListAdd does not duplicate an existing command" {
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command wget"
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command wget"
  [[ "$status" -eq 0 ]]

  local allowListFile="$BATS_TMP_DIR/session/allow-list.json"
  [[ "$(jq --compact-output '.' "$allowListFile")" = '["wget"]' ]]
}

@test "sessionAllowListAdd with an empty command creates nothing" {
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command ''"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/session/allow-list.json" ]]
}

@test "sessionAllowListAdd leaves the session state untouched" {
  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command wget"
  [[ ! -e "$BATS_TMP_DIR/session/state.json" ]]
}

# Empty arguments

@test "empty tool use id is neither stored nor matched" {
  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id '' --command wget"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/session/state.json" ]]

  bats_run_zsh "${sourcePrefix}; approvalRequestGet --tool-use-id ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "empty command is neither counted nor stored" {
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ ! -e "$BATS_TMP_DIR/session/state.json" ]]
}

# No session id

@test "every function is a no-op when CLAUDE_SESSION_ID is empty" {
  export CLAUDE_SESSION_ID=""

  bats_run_zsh "${sourcePrefix}; approvalRequestOpen --tool-use-id toolu_01 --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalRequestGet --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalRequestClose --tool-use-id toolu_01"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountGet --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  bats_run_zsh "${sourcePrefix}; sessionAllowListAdd --command wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]

  # bats_tmp_dir itself writes mock.zsh: only files written by the functions count
  local file
  for file in "$BATS_TMP_DIR"/* "$BATS_TMP_DIR"/.[!.]*; do
    [[ ! -e "$file" || "${file##*/}" = "mock.zsh" ]]
  done
}
