bats_load_library 'helper'

setup() {
  bats_tmp_dir
  PLAN_PROGRESS="$BATS_TEST_DIRNAME/../plan-progress"
  mkdir -p "$BATS_TMP_DIR/plan-dir"
  export PLAN_DIR="$BATS_TMP_DIR/plan-dir"
}

teardown() {
  bats_cleanup
}

@test "outputs done▮total for mixed done values" {
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]},{"id":"03","issue":"i.md","done":false,"blocked_by":[]}]' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮3" ]
}

@test "counts only done==true strictly (null and string excluded)" {
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]},{"id":"03","issue":"i.md","done":null,"blocked_by":[]},{"id":"04","issue":"i.md","done":"true","blocked_by":[]}]' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮4" ]
}

@test "outputs done▮total with all done true" {
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":true,"blocked_by":[]}]' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "2▮2" ]
}

@test "outputs done▮total with all done false" {
  printf '[{"id":"01","issue":"i.md","done":false,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]}]' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮2" ]
}

@test "exits 1 for empty array" {
  printf '[]' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "exits 1 for malformed JSON" {
  printf 'not valid json' > "$PLAN_DIR/state.json"
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "exits 1 when state.json is missing" {
  bats_run_zsh "$PLAN_PROGRESS" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "deduces directory from worktree context when called with no argument" {
  bats_git_dir 'repo'
  local wt_path="$(bats_git_worktree 'feat/no-arg')"
  mkdir -p "$wt_path/plans/feat_no-arg"
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]}]' > "$wt_path/plans/feat_no-arg/state.json"
  echo '{}' > "$wt_path/plans/feat_no-arg/ralph.json"
  cd "$wt_path"
  bats_run_zsh "$PLAN_PROGRESS"
  [ "$status" -eq 0 ]
  [ "$output" = "1▮2" ]
}
