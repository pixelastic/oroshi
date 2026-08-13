bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "init creates state file with given mode" {
  bats_run_zsh "ralph-state $DIR init loop"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r .mode "$DIR/ralph.json")" = "loop" ]]
  [[ "$(jq -r .done "$DIR/ralph.json")" = "false" ]]
  [[ "$(jq -r .prd_done "$DIR/ralph.json")" = "false" ]]
}

@test "init defaults to single mode" {
  bats_run_zsh "ralph-state $DIR init"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r .mode "$DIR/ralph.json")" = "single" ]]
}

@test "get returns value" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$DIR/ralph.json"
  [[ -f "$DIR/ralph.json" ]]
  bats_run_zsh "ralph-state $DIR get mode"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "loop" ]]
}

@test "set updates a boolean value" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$DIR/ralph.json"
  bats_run_zsh "ralph-state $DIR set done true"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r .done "$DIR/ralph.json")" = "true" ]]
}

@test "clear removes state file" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$DIR/ralph.json"
  [[ -f "$DIR/ralph.json" ]]
  bats_run_zsh "ralph-state $DIR clear"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$DIR/ralph.json" ]]
}

@test "fails without dir argument" {
  bats_run_zsh "ralph-state"
  [[ "$status" -ne 0 ]]
}
