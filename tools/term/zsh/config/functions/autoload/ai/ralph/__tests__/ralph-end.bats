bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/prd-dir"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"
  export WORKTREE="$BATS_TMP_DIR/worktree"
  export CALLS="$BATS_TMP_DIR/calls"

  # Safety net for every test: the real queue and the real Claude must never be reached.
  # ralph-mode resolves through plan-directory, so it would ignore the sandbox ralph.json.
  ralph-mode() { jq --raw-output '.mode // empty' "$1/ralph.json" 2>/dev/null; }
  zsh-queue-write() { echo "queue: $1" >>"$CALLS"; }
  claude-stop() { echo "stop" >>"$CALLS"; }
  bats_mock ralph-mode zsh-queue-write claude-stop
}

@test "does nothing in single-shot mode" {
  jq -n '{"mode":"single"}' > "$PRD_DIR/ralph.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"single"}' ]]
}

@test "does not modify ralph.json in auto mode" {
  mock_auto_collaborators
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(jq -c . "$PRD_DIR/ralph.json")" = '{"mode":"auto"}' ]]
}

@test "does not modify state.json" {
  mock_auto_collaborators
  local before="$(cat "$PRD_DIR/state.json")"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$PRD_DIR/state.json")" = "$before" ]]
}

@test "fails without dir argument" {
  bats_run_zsh "ralph-end"
  [[ "$status" -ne 0 ]]
}

# Mocks the plan collaborators of auto mode. The queue and Claude stop log to $CALLS, in order.
mock_auto_collaborators() {
  jq -n '{"mode":"auto"}' >"$PRD_DIR/ralph.json"
  printf '{"branchedAt":"abc123","issues":[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]}' >"$PRD_DIR/state.json"

  plan-worktree() { echo "$WORKTREE"; }
  bats_mock plan-worktree
}

@test "auto: queues exactly ralph-auto-next with the worktree" {
  mock_auto_collaborators
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(grep "queue:" "$CALLS")" == "queue: ralph-auto-next $WORKTREE" ]]
}

@test "auto: shell-quotes the worktree in the queued line" {
  mock_auto_collaborators
  export WORKTREE="$BATS_TMP_DIR/work tree"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$(grep "queue:" "$CALLS")" == "queue: ralph-auto-next $BATS_TMP_DIR/work\\ tree" ]]
}

@test "auto: queues the command before stopping Claude" {
  mock_auto_collaborators
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$(cut -d: -f1 "$CALLS" | tr '\n' ' ')" == "queue stop " ]]
}

@test "single: queues nothing and does not stop Claude" {
  mock_auto_collaborators
  jq -n '{"mode":"single"}' >"$PRD_DIR/ralph.json"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$CALLS" ]]
}
