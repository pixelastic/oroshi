bats_load_library 'helper'

setup() {
  bats_tmp_dir
  STOP_HOOK="$BATS_TEST_DIRNAME/../stop"
  audio-play-oroshi() { echo "$1" > "$BATS_TMP_DIR/sound-played"; }
  bats_mock audio-play-oroshi
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

# Mock helpers for attention tests
mock_kitty_attention() {
  kitty-window-tab-id() { echo "5"; }
  bats_mock kitty-window-tab-id
  kitty-tab-focused() { return 1; }
  bats_mock kitty-tab-focused
  kitty-tab-attention-add() { touch "$BATS_TMP_DIR/attention-added"; }
  bats_mock kitty-tab-attention-add
}

@test "attention: added when tab not focused, even with sound disabled" {
  export KITTY_WINDOW_ID="42"
  export OROSHI_CLAUDE_STOP_SOUND="no"
  mock_kitty_attention

  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/attention-added" ]
}

@test "attention: not added for subagents" {
  export KITTY_WINDOW_ID="42"
  export OROSHI_CLAUDE_STOP_SOUND="no"
  mock_kitty_attention

  run_stop '{"transcript_path":"/home/user/.claude/sessions/abc/subagents/xyz.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/attention-added" ]
}

@test "attention: not added when KITTY_WINDOW_ID absent" {
  unset KITTY_WINDOW_ID
  export OROSHI_CLAUDE_STOP_SOUND="no"
  kitty-tab-attention-add() { touch "$BATS_TMP_DIR/attention-added"; }
  bats_mock kitty-tab-attention-add

  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/attention-added" ]
}

@test "attention: not added when tab is focused" {
  export KITTY_WINDOW_ID="42"
  export OROSHI_CLAUDE_STOP_SOUND="no"
  kitty-window-tab-id() { echo "5"; }
  kitty-tab-focused() { return 0; }
  kitty-tab-attention-add() { touch "$BATS_TMP_DIR/attention-added"; }
  bats_mock kitty-window-tab-id kitty-tab-focused kitty-tab-attention-add

  run_stop '{"transcript_path":"/some/path.jsonl"}'

  [ "$status" -eq 0 ]
  [ ! -f "$BATS_TMP_DIR/attention-added" ]
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

@test "auto: plays fast sound when stdin has escaped newlines in last_assistant_message" {
  local transcriptPath="$BATS_TMP_DIR/session.jsonl"
  make_transcript "$transcriptPath" 1

  export OROSHI_CLAUDE_STOP_SOUND="auto"
  # \n in last_assistant_message (e.g. code blocks) must not corrupt JSON parsing
  run_stop "{\"transcript_path\":\"$transcriptPath\",\"last_assistant_message\":\"line1\\nline2\"}"

  [ "$status" -eq 0 ]
  [ "$(cat "$BATS_TMP_DIR/sound-played")" = "claude-stop-fast.mp3" ]
}
