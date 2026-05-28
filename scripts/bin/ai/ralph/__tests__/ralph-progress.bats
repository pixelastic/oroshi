bats_load_library 'helper'

RALPH_PROGRESS="$BATS_TEST_DIRNAME/../ralph-progress"

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
}

teardown() {
  bats_cleanup
}

@test "outputs done▮total for mixed passes values" {
  printf '[{"passes":true},{"passes":false},{"passes":false}]' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮3" ]
}

@test "counts only passes==true strictly (null and string excluded)" {
  printf '[{"passes":true},{"passes":false},{"passes":null},{"passes":"true"}]' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮4" ]
}

@test "outputs done▮total with all passes true" {
  printf '[{"passes":true},{"passes":true}]' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "2▮2" ]
}

@test "outputs done▮total with all passes false" {
  printf '[{"passes":false},{"passes":false}]' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮2" ]
}

@test "exits 1 for empty array" {
  printf '[]' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 1 ]
}

@test "exits 1 for malformed JSON" {
  printf 'not valid json' > "$PRD_DIR/issues.json"
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 1 ]
}

@test "exits 1 when prd.json is missing" {
  bats_run_script "$RALPH_PROGRESS" "$PRD_DIR"
  [ "$status" -eq 1 ]
}

@test "deduces directory from worktree context when called with no argument" {
  bats_git_dir 'repo'
  local wt_path="$(bats_git_worktree 'feat/no-arg')"
  mkdir -p "$wt_path/ralph/feat_no-arg"
  printf '[{"passes":true},{"passes":false}]' > "$wt_path/ralph/feat_no-arg/issues.json"
  cd "$wt_path"
  bats_run_script "$RALPH_PROGRESS"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮2" ]
}
