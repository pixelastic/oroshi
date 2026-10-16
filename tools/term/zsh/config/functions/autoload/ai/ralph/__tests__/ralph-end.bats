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

  plan-progress() { echo "${PROGRESS:-1▮3}"; }
  plan-worktree() { echo "$WORKTREE"; }
  bats_mock plan-progress
  bats_mock plan-worktree
}

@test "auto: with issues remaining, queues commit then ralph --auto" {
  mock_auto_collaborators
  export PROGRESS="1▮3"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" == "queue: zsh -ic "* ]]
  [[ "$queued" == *"git-commit-create-all-auto && ralph --auto $WORKTREE"* ]]
  [[ "$queued" != *"/review"* ]]
}

@test "auto: after the last issue, queues commit then ralph-review in auto permission mode" {
  mock_auto_collaborators
  export PROGRESS="3▮3"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" == *"git-commit-create-all-auto && claude --permission-mode auto "* ]]
  [[ "$queued" == *"/ralph-review $PRD_DIR"* ]]
  [[ "$queued" != *"ralph --auto"* ]]
}

@test "auto: after the last issue, does not queue a bare review" {
  mock_auto_collaborators
  export PROGRESS="3▮3"
  bats_run_zsh "ralph-end $PRD_DIR"
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" != *"/review"* ]]
  [[ "$queued" != *"branchedAt"* ]]
  [[ "$queued" != *"abc123"* ]]
}

@test "auto: queued command is one SIGINT-safe group run by a child shell" {
  mock_auto_collaborators
  bats_run_zsh "ralph-end $PRD_DIR"
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" == "queue: zsh -ic '{ "* ]]
  [[ "$queued" == *"; }'" ]]
}

# exec from the queue hook kills the Kitty window before the new shell runs anything
@test "auto: queued command never execs, so the window shell stays alive" {
  mock_auto_collaborators
  bats_run_zsh "ralph-end $PRD_DIR"
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" != *"exec "* ]]
  [[ "$queued" != *"9>"* ]]
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
