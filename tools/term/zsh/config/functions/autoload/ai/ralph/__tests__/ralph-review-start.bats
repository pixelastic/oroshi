bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/plan-dir/issues"
  export PLAN_DIR="$BATS_TMP_DIR/plan-dir"
}

@test "outputs status:ready with ref from branchedAt to HEAD" {
  printf '{"branchedAt":"abc123","issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ready'
  expect_json '.ref' 'abc123..HEAD'
}

@test "spec is the absolute path of PRD.md in the plan dir" {
  printf '{"branchedAt":"abc123","issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  expect_json '.spec' "$PLAN_DIR/PRD.md"
}

@test "outputs ready even when some issues are not done" {
  printf '{"branchedAt":"abc123","issues":[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]},
    {"id":"02","issue":"issues/02-bar.md","done":false,"blocked_by":["01"]}
  ]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 0 ]]
  expect_json '.status' 'ready'
}

@test "returns 1 with an error when state.json is missing" {
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"state.json not found"* ]]
}

@test "returns 1 with an error when branchedAt is missing" {
  printf '{"issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"no branchedAt"* ]]
}

@test "returns 1 with an error when branchedAt is empty" {
  printf '{"branchedAt":"","issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"no branchedAt"* ]]
}

@test "dir without state.json → deduces the plan dir via plan-directory" {
  printf '{"branchedAt":"abc123","issues":[]}' >"$PLAN_DIR/state.json"
  mkdir -p "$BATS_TMP_DIR/worktree"
  plan-directory() { echo "$PLAN_DIR"; }
  bats_mock plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR/worktree && ralph-review-start ."
  [[ "$status" -eq 0 ]]
  expect_json '.spec' "$PLAN_DIR/PRD.md"
}

@test "no arg → deduces the plan dir from the current directory" {
  printf '{"branchedAt":"abc123","issues":[]}' >"$PLAN_DIR/state.json"
  mkdir -p "$BATS_TMP_DIR/worktree"
  plan-directory() { echo "$PLAN_DIR"; }
  bats_mock plan-directory

  bats_run_zsh "cd $BATS_TMP_DIR/worktree && ralph-review-start"
  [[ "$status" -eq 0 ]]
  expect_json '.ref' 'abc123..HEAD'
}
