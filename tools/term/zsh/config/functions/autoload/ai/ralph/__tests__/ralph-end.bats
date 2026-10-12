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

# Mocks the collaborators of auto mode. Each one logs its call to $CALLS, in order.
mock_auto_collaborators() {
  export CALLS="$BATS_TMP_DIR/calls"
  jq -n '{"mode":"auto"}' >"$PRD_DIR/ralph.json"
  printf '{"branchedAt":"abc123","issues":[{"id":"1","issue":"foo.md","done":true,"blocked_by":[]}]}' >"$PRD_DIR/state.json"

  plan-progress() { echo "${PROGRESS:-1▮3}"; }
  zsh-queue-write() { echo "queue: $1" >>"$CALLS"; }
  claude-stop() { echo "stop" >>"$CALLS"; }
  bats_mock plan-progress
  bats_mock zsh-queue-write
  bats_mock claude-stop
}

@test "auto: with issues remaining, queues commit then ralph --auto" {
  mock_auto_collaborators
  export PROGRESS="1▮3"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" == "queue: zsh -ic "* ]]
  [[ "$queued" == *"git-commit-create-all-auto && ralph --auto $PRD_DIR"* ]]
  [[ "$queued" != *"/review"* ]]
}

@test "auto: after the last issue, queues commit then review from branchedAt with the PRD" {
  mock_auto_collaborators
  export PROGRESS="3▮3"
  bats_run_zsh "ralph-end $PRD_DIR"
  [[ "$status" -eq 0 ]]
  local queued="$(grep "queue:" "$CALLS")"
  [[ "$queued" == *"git-commit-create-all-auto && claude"* ]]
  [[ "$queued" == *"/review ref:abc123..HEAD spec:$PRD_DIR/PRD.md"* ]]
  [[ "$queued" != *"ralph --auto"* ]]
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
