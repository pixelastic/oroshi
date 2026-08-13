bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
}

@test "does nothing in single-shot mode" {
  jq -n '{"mode":"single","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.done' "$PRD_DIR/ralph.json")" != "true" ]]
  [[ "$(jq -r '.prd_done' "$PRD_DIR/ralph.json")" != "true" ]]
}

@test "sets done=true in loop mode with open issues" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  printf '[{"id":"1","issue":"foo.md","done":false,"blocked_by":[]}]' > "$PRD_DIR/state.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.done' "$PRD_DIR/ralph.json")" = "true" ]]
  [[ "$(jq -r '.prd_done' "$PRD_DIR/ralph.json")" != "true" ]]
}

@test "sets done=true and prd_done=true in loop mode when all issues complete" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  printf '[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]' > "$PRD_DIR/state.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.done' "$PRD_DIR/ralph.json")" = "true" ]]
  [[ "$(jq -r '.prd_done' "$PRD_DIR/ralph.json")" = "true" ]]
}

@test "sets only done=true in loop mode when state.json is absent" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.done' "$PRD_DIR/ralph.json")" = "true" ]]
  [[ "$(jq -r '.prd_done' "$PRD_DIR/ralph.json")" != "true" ]]
}

@test "sets only done=true in loop mode when state.json is malformed" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  echo 'not valid json' > "$PRD_DIR/state.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.done' "$PRD_DIR/ralph.json")" = "true" ]]
  [[ "$(jq -r '.prd_done' "$PRD_DIR/ralph.json")" != "true" ]]
}

@test "does not modify state.json" {
  jq -n '{"mode":"loop","done":false,"prd_done":false}' > "$PRD_DIR/ralph.json"
  printf '[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]' > "$PRD_DIR/state.json"
  local before="$(cat "$PRD_DIR/state.json")"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$PRD_DIR/state.json")" = "$before" ]]
}
