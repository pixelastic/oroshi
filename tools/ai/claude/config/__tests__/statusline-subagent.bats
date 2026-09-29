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

subagent_run() {
  subagent_json "$@" >"${BATS_TMP_DIR}/input.json"
  bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline-subagent" <"${BATS_TMP_DIR}/input.json"
}

@test "writes one entry per running task with its id and status" {
  subagent_run "a1:local_agent:running" "a2:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a1","status":"running"},{"id":"a2","status":"running"}]' ]]
}

@test "ignores completed, killed, and failed tasks" {
  subagent_run "a1:local_agent:completed" "a2:local_agent:running" "a3:local_agent:killed" "a4:local_agent:failed"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[{"id":"a2","status":"running"}]' ]]
}

@test "writes an empty subagents list when no task is running" {
  subagent_run "a1:local_agent:completed" "a2:local_agent:killed"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.subagents' "$STATE_FILE")" == '[]' ]]
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

@test "prints nothing on stdout" {
  subagent_run "a1:local_agent:running"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
