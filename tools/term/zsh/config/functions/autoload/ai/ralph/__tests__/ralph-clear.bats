bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "removes ralph.json" {
  jq -n '{"mode":"single","done":false,"prd_done":false}' > "$DIR/ralph.json"
  [[ -f "$DIR/ralph.json" ]]
  bats_run_zsh "ralph-clear $DIR"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$DIR/ralph.json" ]]
}

@test "succeeds when no ralph.json exists" {
  [[ ! -f "$DIR/ralph.json" ]]
  bats_run_zsh "ralph-clear $DIR"
  [[ "$status" -eq 0 ]]
}

@test "fails without dir and no plan-directory" {
  plan-directory() { return 1; }
  bats_mock plan-directory
  bats_run_zsh "ralph-clear"
  [[ "$status" -ne 0 ]]
}
