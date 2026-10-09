bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
}

@test "does nothing in single-shot mode" {
  jq -n '{"mode":"single"}' > "$PRD_DIR/ralph.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"single"}' ]]
}

@test "does not modify ralph.json in auto mode" {
  jq -n '{"mode":"auto"}' > "$PRD_DIR/ralph.json"
  printf '{"branchedAt":"abc","issues":[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]}' > "$PRD_DIR/state.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"auto"}' ]]
}

@test "does not modify state.json" {
  jq -n '{"mode":"auto"}' > "$PRD_DIR/ralph.json"
  printf '{"branchedAt":"abc","issues":[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]}' > "$PRD_DIR/state.json"
  local before="$(cat "$PRD_DIR/state.json")"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$PRD_DIR/state.json")" = "$before" ]]
}

@test "fails without dir argument" {
  bats_run_zsh "ralph-end"
  [[ "$status" -ne 0 ]]
}
