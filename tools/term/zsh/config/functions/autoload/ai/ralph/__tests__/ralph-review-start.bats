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

@test "returns 1 when state.json is missing" {
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when branchedAt is missing" {
  printf '{"issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when branchedAt is empty" {
  printf '{"branchedAt":"","issues":[]}' >"$PLAN_DIR/state.json"
  bats_run_zsh "ralph-review-start $PLAN_DIR"
  [[ "$status" -eq 1 ]]
}
