bats_load_library 'helper'

STOP_HOOK="$BATS_TEST_DIRNAME/../stop"

setup() {
  bats_tmp_dir
  audio-play-oroshi() { echo "$1" > "$BATS_TMP_DIR/sound-played"; }
  bats_mock audio-play-oroshi
}

teardown() {
  bats_cleanup
}

# Run the stop hook with a given env var value and stdin JSON
run_stop() {
  local stdinJson="$1"
  local mock_file="$BATS_TMP_DIR/mock.zsh"
  run zsh -c "[[ -f '${mock_file}' ]] && source '${mock_file}'; source '${STOP_HOOK}'" <<< "$stdinJson"
}

# Create a minimal transcript with a user message N seconds ago
make_transcript() {
  local path="$1"
  local secsAgo="${2:-60}"
  local ts="$(date -d "${secsAgo} seconds ago" --utc +%Y-%m-%dT%H:%M:%SZ)"
  echo '{"type":"user","timestamp":"'"$ts"'"}' > "$path"
}

@test "silent when OROSHI_CLAUDE_STOP_SOUND is no" {
  export OROSHI_CLAUDE_STOP_SOUND="no"
  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/sound-played" ]
}

@test "silent when OROSHI_CLAUDE_STOP_SOUND is empty" {
  export OROSHI_CLAUDE_STOP_SOUND=""
  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/sound-played" ]
}

@test "silent for subagents even when OROSHI_CLAUDE_STOP_SOUND=auto" {
  export OROSHI_CLAUDE_STOP_SOUND="auto"
  run_stop '{"transcript_path":"/home/user/.claude/sessions/abc/subagents/xyz.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/sound-played" ]
}

@test "plays custom sound directly when OROSHI_CLAUDE_STOP_SOUND is a filename" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath"

  export OROSHI_CLAUDE_STOP_SOUND="my-custom.mp3"
  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/sound-played")" = "my-custom.mp3" ]
}

@test "auto: plays slow sound when duration >= threshold" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 60

  export OROSHI_CLAUDE_STOP_SOUND="auto"
  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/sound-played")" = "claude-stop.mp3" ]
}

@test "auto: plays fast sound when duration < threshold" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 1

  export OROSHI_CLAUDE_STOP_SOUND="auto"
  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/sound-played")" = "claude-stop-fast.mp3" ]
}
