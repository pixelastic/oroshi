bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "prints the mode" {
  jq -n '{"mode":"auto"}' > "$DIR/ralph.json"
  bats_run_zsh "ralph-mode $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "auto" ]]
}

@test "prints nothing when no session is running" {
  bats_run_zsh "ralph-mode $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "no arg + worktree has plan → reads the plan directory" {
  plan-directory() { echo "$DIR"; }
  bats_mock plan-directory
  jq -n '{"mode":"auto"}' > "$DIR/ralph.json"

  bats_run_zsh "cd / && ralph-mode"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "auto" ]]
}

@test "no arg + no worktree plan → falls back to cwd" {
  plan-directory() { return 1; }
  bats_mock plan-directory
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"

  bats_run_zsh "cd $DIR && ralph-mode"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "single" ]]
}
