bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR/sessions"
  export STATE_FILE="$CLAUDE_SESSIONS_DIR/abc-123/statusline.json"
}

# Build a subagentStatusLine payload from "id:type:status" arguments
subagent_json() {
  local tasks=()
  for task in "$@"; do
    local taskId taskType taskStatus
    IFS=: read -r taskId taskType taskStatus <<<"$task"
    tasks+=("$(jo id="$taskId" type="$taskType" status="$taskStatus")")
  done
  jo session_id=abc-123 columns=120 tasks="$(jo -a "${tasks[@]}")"
}

# Run statusline-subagent on the input.json fixture
subagent_exec() {
  bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline-subagent" <"${BATS_TMP_DIR}/input.json"
}

subagent_run() {
  subagent_json "$@" >"${BATS_TMP_DIR}/input.json"
  subagent_exec
}

@test "writes one entry per running task with its id and status" {
  subagent_run "a1:local_agent:running" "a2:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a1","status":"running","description":""},{"id":"a2","status":"running","description":""}]' ]]
}

@test "ignores completed, killed, and failed tasks" {
  subagent_run "a1:local_agent:completed" "a2:local_agent:running" "a3:local_agent:killed" "a4:local_agent:failed"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a2","status":"running","description":""}]' ]]
}

@test "writes pending tasks with status pending" {
  subagent_run "b1:local_bash:pending"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"b1","status":"pending","description":""}]' ]]
}

@test "writes pending and running tasks in their input order" {
  subagent_run "a1:local_agent:running" "b1:local_bash:pending" "a2:local_agent:completed" "a3:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a1","status":"running","description":""},{"id":"b1","status":"pending","description":""},{"id":"a3","status":"running","description":""}]' ]]
}

@test "writes an empty subagents list when no task is pending or running" {
  subagent_run "a1:local_agent:completed" "a2:local_agent:killed"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[]' ]]
}

@test "saves the description of each task" {
  jo session_id=abc-123 tasks="$(jo -a "$(jo id=a1 type=local_agent status=running description="Code review")")" >"${BATS_TMP_DIR}/input.json"
  subagent_exec
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a1","status":"running","description":"Code review"}]' ]]
}

@test "keeps running tasks of any type" {
  subagent_run "a1:local_agent:running" "b1:local_bash:running" "w1:local_workflow:running"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '[.subagents[].id]' "$STATE_FILE")" == '["a1","b1","w1"]' ]]
}

@test "creates the session directory when it does not exist" {
  [[ ! -e "$CLAUDE_SESSIONS_DIR" ]]
  subagent_run "a1:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ -f "$STATE_FILE" ]]
}

@test "preserves other top-level keys of an existing statusline.json" {
  mkdir -p "$CLAUDE_SESSIONS_DIR/abc-123"
  echo '{"other":{"key":"value"},"subagents":[{"id":"old","status":"running"}]}' >"$STATE_FILE"

  subagent_run "a1:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.other' "$STATE_FILE")" == '{"key":"value"}' ]]
  [[ "$(jq --compact-output '[.subagents[].id]' "$STATE_FILE")" == '["a1"]' ]]
}

@test "prints one hiding line per task with its id and an empty content" {
  subagent_run "a1:local_agent:running" "b1:local_bash:pending"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == '{"id":"a1","content":""}' ]]
  [[ "${lines[1]}" == '{"id":"b1","content":""}' ]]
}

@test "prints hiding lines for tasks of every status" {
  subagent_run "a1:local_agent:completed" "a2:local_agent:killed" "a3:local_agent:failed" "w1:local_workflow:paused"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --slurp --compact-output '[.[].id]' <<<"$output")" == '["a1","a2","a3","w1"]' ]]
}

@test "prints valid JSON on each line" {
  subagent_run "a1:local_agent:running" "a2:local_agent:completed"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  for line in "${lines[@]}"; do
    jq --exit-status '.content == ""' <<<"$line"
  done
}

@test "prints nothing when the tasks list is empty" {
  echo '{"session_id":"abc-123","columns":120,"tasks":[]}' >"${BATS_TMP_DIR}/input.json"
  subagent_exec
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints hiding lines even without a session id" {
  jo columns=120 tasks="$(jo -a "$(jo id=a1 type=local_agent status=running)")" >"${BATS_TMP_DIR}/input.json"
  subagent_exec
  [[ "$status" -eq 0 ]]
  [[ "$output" == '{"id":"a1","content":""}' ]]
}
