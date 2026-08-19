bats_load_library 'helper'

setup() {
  bats_tmp_dir
  STOP_HOOK="$BATS_TEST_DIRNAME/../stop"
  kitty-notify() { printf '%s' "$*" > "$BATS_TMP_DIR/kitty-notify-args"; }
  bats_mock kitty-notify
}

# Run the stop hook with a given env var value and stdin JSON
run_stop() {
  local stdinJson="$1"
  bats_run_zsh "$STOP_HOOK" <<< "$stdinJson"
}

# Create a minimal transcript with a user message N seconds ago
make_transcript() {
  local path="$1"
  local secsAgo="${2:-60}"
  local ts="$(date -d "${secsAgo} seconds ago" --utc +%Y-%m-%dT%H:%M:%SZ)"
  echo '{"type":"user","timestamp":"'"$ts"'"}' > "$path"
}

@test "calls kitty-notify --sound claude-stop.mp3 for slow responses" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 60
  export OROSHI_CLAUDE_STOP_SOUND="auto"

  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-stop.mp3" ]]
}

@test "calls kitty-notify --sound claude-stop-fast.mp3 for fast responses" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 1
  export OROSHI_CLAUDE_STOP_SOUND="auto"

  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-stop-fast.mp3" ]]
}

@test "calls kitty-notify --sound with custom sound when OROSHI_CLAUDE_STOP_SOUND is a custom value" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath"
  export OROSHI_CLAUDE_STOP_SOUND="my-custom.mp3"

  run_stop "{\"transcript_path\":\"$transcriptPath\"}"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound my-custom.mp3" ]]
}

@test "calls kitty-notify --sound no when OROSHI_CLAUDE_STOP_SOUND is no" {
  export OROSHI_CLAUDE_STOP_SOUND="no"

  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound no" ]]
}

@test "calls kitty-notify --sound no when OROSHI_CLAUDE_STOP_SOUND is empty" {
  export OROSHI_CLAUDE_STOP_SOUND=""

  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound no" ]]
}

@test "skips entirely for subagent completions" {
  export OROSHI_CLAUDE_STOP_SOUND="auto"

  run_stop '{"transcript_path":"/home/user/.claude/sessions/abc/subagents/xyz.jsonl"}'

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/kitty-notify-args" ]]
}

@test "auto: handles escaped newlines in last_assistant_message" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 1
  export OROSHI_CLAUDE_STOP_SOUND="auto"

  run_stop "{\"transcript_path\":\"$transcriptPath\",\"last_assistant_message\":\"line1\\nline2\"}"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-stop-fast.mp3" ]]
}
