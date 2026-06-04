bats_load_library 'helper'

RALPH_START="$BATS_TEST_DIRNAME/../ralph-start"

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/plan-dir/issues"
  export PLAN_DIR="$BATS_TMP_DIR/plan-dir"
}

teardown() {
  bats_cleanup
}

@test "outputs status:ready with first eligible issue" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.status')" = "ready" ]
  [ "$(echo "$output" | jq -r '.id')" = "01" ]
}

@test "picks lowest id when multiple eligible" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":true, "blocked_by":[]},
    {"id":"02","issue":"issues/02-bar.md","done":false,"blocked_by":[]},
    {"id":"03","issue":"issues/03-baz.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.id')" = "02" ]
}

@test "skips issues with unresolved blockers" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]},
    {"id":"02","issue":"issues/02-bar.md","done":false,"blocked_by":["01"]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.id')" = "01" ]
}

@test "all paths in output are absolute" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [[ "$(echo "$output" | jq -r '.issue')" == /* ]]
  [[ "$(echo "$output" | jq -r '.state')" == /* ]]
  [[ "$(echo "$output" | jq -r '.guidance')" == /* ]]
  [[ "$(echo "$output" | jq -r '.review_log')" == /* ]]
}

@test "issue resolves relative path from plan dir" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.issue')" = "$PLAN_DIR/issues/01-foo.md" ]
}

@test "outputs status:finished when all issues complete" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":true,"blocked_by":[]},
    {"id":"02","issue":"issues/02-bar.md","done":true,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.status')" = "finished" ]
}

@test "outputs status:deadlocked when all issues are blocked" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":["02"]},
    {"id":"02","issue":"issues/02-bar.md","done":false,"blocked_by":["01"]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.status')" = "deadlocked" ]
}

@test "exits 1 when state.json is missing" {
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "exits 1 when state.json is malformed" {
  printf 'not valid json' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "picks lowest id even when state.json is out of order" {
  printf '[
    {"id":"03","issue":"issues/03-baz.md","done":false,"blocked_by":[]},
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]},
    {"id":"02","issue":"issues/02-bar.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.id')" = "01" ]
}

@test "creates ralph.json with mode=single when absent" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ -f "$PLAN_DIR/ralph.json" ]
  [ "$(jq -r '.mode' "$PLAN_DIR/ralph.json")" = "single" ]
}

@test "fails when single-shot session already active" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  ralph-state "$PLAN_DIR" init single
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 1 ]
}

@test "does not overwrite ralph.json when already present" {
  printf '[
    {"id":"01","issue":"issues/01-foo.md","done":false,"blocked_by":[]}
  ]' >"$PLAN_DIR/state.json"
  ralph-state "$PLAN_DIR" init loop
  bats_run_script "$RALPH_START" "$PLAN_DIR"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.mode' "$PLAN_DIR/ralph.json")" = "loop" ]
}
