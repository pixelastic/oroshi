bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/ai/meetup-announce/__lib/resolve-draft-dir.zsh'"
  DRAFT_ROOT="$BATS_TMP_DIR/claude/meetup-announce"
}

# -- First run --

@test "creates draft directory and assets/ subdirectory" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  [[ "$status" -eq 0 ]]
  [[ -d "$DRAFT_ROOT/recABC123" ]]
  [[ -d "$DRAFT_ROOT/recABC123/assets" ]]
}

@test "creates state.json with meetupId and meetupName" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  local stateFile="$DRAFT_ROOT/recABC123/state.json"
  [[ -f "$stateFile" ]]
  [[ "$(jq -r '.meetupId' "$stateFile")" == "recABC123" ]]
  [[ "$(jq -r '.meetupName' "$stateFile")" == "Paris Meetup" ]]
}

@test "creates state.json with all 9 messages set to pending" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  local stateFile="$DRAFT_ROOT/recABC123/state.json"

  local messageCount="$(jq '.messages | length' "$stateFile")"
  [[ "$messageCount" -eq 9 ]]

  local allPending="$(jq '[.messages[].state] | all(. == "pending")' "$stateFile")"
  [[ "$allPending" == "true" ]]

  # Verify exact message IDs
  [[ "$(jq -r '.messages["early--office-paris--initial"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["early--office-paris--reminder"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["early--team-devmarketing--initial"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["early--help-recruiting--initial"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["early--help-recruiting--reminder"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["early--topic-relevant--initial"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["last--office-paris--reminder"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["last--office-paris--reminder-today"].state' "$stateFile")" == "pending" ]]
  [[ "$(jq -r '.messages["last--team-devmarketing--reminder"].state' "$stateFile")" == "pending" ]]
}

@test "outputs the draft directory path" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$DRAFT_ROOT/recABC123" ]]
}

# -- Subsequent run --

@test "reuses existing directory without recreating" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"

  # Place a marker file to prove directory is reused, not recreated
  echo "marker" > "$DRAFT_ROOT/recABC123/marker.txt"

  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  [[ "$status" -eq 0 ]]
  [[ -f "$DRAFT_ROOT/recABC123/marker.txt" ]]
}

@test "updates meetupName in state.json if it changed" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup v2'"

  local stateFile="$DRAFT_ROOT/recABC123/state.json"
  [[ "$(jq -r '.meetupName' "$stateFile")" == "Paris Meetup v2" ]]
}

@test "preserves existing message states on reuse" {
  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"

  # Simulate a message being drafted
  local stateFile="$DRAFT_ROOT/recABC123/state.json"
  local updated="$(jq '.messages["early--office-paris--initial"].state = "drafted"' "$stateFile")"
  echo "$updated" > "$stateFile"

  bats_run_zsh "$sourcePrefix && resolve-draft-dir recABC123 'Paris Meetup'"

  [[ "$(jq -r '.messages["early--office-paris--initial"].state' "$stateFile")" == "drafted" ]]
  [[ "$(jq -r '.messages["early--office-paris--reminder"].state' "$stateFile")" == "pending" ]]
}
