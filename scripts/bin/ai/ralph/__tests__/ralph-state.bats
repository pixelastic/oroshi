bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export RALPH_STATE_FILE="$BATS_TMP_DIR/ralph-state.json"
}

teardown() {
  bats_cleanup
}

@test "init creates state file with given mode" {
  run ralph-state init loop
  [ "$status" -eq 0 ]
  [ "$(jq -r .mode "$RALPH_STATE_FILE")" = "loop" ]
  [ "$(jq -r .done "$RALPH_STATE_FILE")" = "false" ]
  [ "$(jq -r .prd_done "$RALPH_STATE_FILE")" = "false" ]
}

@test "init defaults to single mode" {
  run ralph-state init
  [ "$status" -eq 0 ]
  [ "$(jq -r .mode "$RALPH_STATE_FILE")" = "single" ]
}

@test "get returns value" {
  ralph-state init loop
  run ralph-state get mode
  [ "$status" -eq 0 ]
  [ "$output" = "loop" ]
}

@test "set updates a boolean value" {
  ralph-state init loop
  run ralph-state set done true
  [ "$status" -eq 0 ]
  [ "$(jq -r .done "$RALPH_STATE_FILE")" = "true" ]
}

@test "clear removes state file" {
  ralph-state init loop
  run ralph-state clear
  [ "$status" -eq 0 ]
  [ ! -f "$RALPH_STATE_FILE" ]
}

@test "fails when RALPH_STATE_FILE not set" {
  unset RALPH_STATE_FILE
  run ralph-state get mode
  [ "$status" -ne 0 ]
}
