bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "removes ralph.json" {
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"
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

@test "no arg + worktree has plan → clears the plan directory" {
  plan-directory() { echo "$DIR"; }
  bats_mock plan-directory
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"

  bats_run_zsh "cd / && ralph-clear"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$DIR/ralph.json" ]]
}

@test "no arg + no worktree plan → falls back to cwd" {
  plan-directory() { return 1; }
  bats_mock plan-directory
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"

  bats_run_zsh "cd $DIR && ralph-clear"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$DIR/ralph.json" ]]
}
