bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/plan-dir"
  export PLAN_DIR="$BATS_TMP_DIR/plan-dir"
}

@test "outputs done▮total for mixed done values" {
  printf '{"issues":[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]},{"id":"03","issue":"i.md","done":false,"blocked_by":[]}]}' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "1▮3" ]]
}

@test "counts only done==true strictly (null and string excluded)" {
  printf '{"issues":[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]},{"id":"03","issue":"i.md","done":null,"blocked_by":[]},{"id":"04","issue":"i.md","done":"true","blocked_by":[]}]}' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "1▮4" ]]
}

@test "outputs done▮total with all done true" {
  printf '{"issues":[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":true,"blocked_by":[]}]}' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "2▮2" ]]
}

@test "outputs done▮total with all done false" {
  printf '{"issues":[{"id":"01","issue":"i.md","done":false,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]}]}' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "0▮2" ]]
}

@test "exits 1 when issues is empty" {
  printf '{"issues":[]}' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for malformed JSON" {
  printf 'not valid json' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when state.json is missing" {
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}

@test "deduces directory from worktree context when called with no argument" {
  bats_plans_dir
  local planDirectory="$MOCK_OROSHI_PLANS_DIR/repo--feat_no-arg"
  mkdir -p "$planDirectory"
  printf '{"issues":[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]}]}' > "$planDirectory/state.json"

  plan-directory() { echo "$BATS_TMP_DIR/plans/repo--feat_no-arg"; }
  bats_mock plan-directory

  bats_run_zsh "plan-progress"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "1▮2" ]]
}

@test "exits 1 on a bare array" {
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]}]' > "$PLAN_DIR/state.json"
  bats_run_zsh "plan-progress $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}
