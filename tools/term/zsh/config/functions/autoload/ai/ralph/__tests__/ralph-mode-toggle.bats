bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export DIR="$BATS_TMP_DIR"
}

@test "flips single to auto" {
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"
  bats_run_zsh "ralph-mode-toggle $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.mode' "$DIR/ralph.json")" = "auto" ]]
}

@test "flips auto to single" {
  jq -n '{"mode":"auto"}' > "$DIR/ralph.json"
  bats_run_zsh "ralph-mode-toggle $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.mode' "$DIR/ralph.json")" = "single" ]]
}

@test "preserves other fields of ralph.json" {
  jq -n '{"mode":"single","issue":"03","pid":42}' > "$DIR/ralph.json"
  bats_run_zsh "ralph-mode-toggle $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output --sort-keys '.' "$DIR/ralph.json")" = '{"issue":"03","mode":"auto","pid":42}' ]]
}

@test "does nothing when ralph.json does not exist" {
  bats_run_zsh "ralph-mode-toggle $DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "does not create ralph.json" {
  bats_run_zsh "ralph-mode-toggle $DIR"
  [[ ! -f "$DIR/ralph.json" ]]
}

@test "no arg + worktree has plan → toggles the plan directory" {
  plan-directory() { echo "$DIR"; }
  bats_disable_worktree_aware
  bats_mock plan-directory
  jq -n '{"mode":"single"}' > "$DIR/ralph.json"

  bats_run_zsh "cd / && ralph-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.mode' "$DIR/ralph.json")" = "auto" ]]
}

@test "no arg + no worktree plan → falls back to cwd" {
  plan-directory() { return 1; }
  bats_disable_worktree_aware
  bats_mock plan-directory
  jq -n '{"mode":"auto"}' > "$DIR/ralph.json"

  bats_run_zsh "cd $DIR && ralph-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.mode' "$DIR/ralph.json")" = "single" ]]
}
