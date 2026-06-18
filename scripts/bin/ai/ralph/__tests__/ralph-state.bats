bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "init creates state file with given mode" {
  run ralph-state "$DIR" init loop
  [ "$status" -eq 0 ]
  [ "$(jq -r .mode "$DIR/ralph.json")" = "loop" ]
  [ "$(jq -r .done "$DIR/ralph.json")" = "false" ]
  [ "$(jq -r .prd_done "$DIR/ralph.json")" = "false" ]
}

@test "init defaults to single mode" {
  run ralph-state "$DIR" init
  [ "$status" -eq 0 ]
  [ "$(jq -r .mode "$DIR/ralph.json")" = "single" ]
}

@test "get returns value" {
  ralph-state "$DIR" init loop
  [ -f "$DIR/ralph.json" ]
  run ralph-state "$DIR" get mode
  [ "$status" -eq 0 ]
  [ "$output" = "loop" ]
}

@test "set updates a boolean value" {
  ralph-state "$DIR" init loop
  run ralph-state "$DIR" set 'done' true
  [ "$status" -eq 0 ]
  [ "$(jq -r .done "$DIR/ralph.json")" = "true" ]
}

@test "clear removes state file" {
  ralph-state "$DIR" init loop
  [ -f "$DIR/ralph.json" ]
  run ralph-state "$DIR" clear
  [ "$status" -eq 0 ]
  [ ! -f "$DIR/ralph.json" ]
}

@test "fails without dir argument" {
  run ralph-state
  [ "$status" -ne 0 ]
}
