bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "errors with usage when no arguments provided" {
  studio-pack-generator() { :; }
  bats_mock studio-pack-generator

  bats_run_zsh "rss2lunii"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "calls studio-pack-generator with opinionated defaults" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  bats_run_zsh "rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--rss-split-length 9999"* ]]
  [[ "$args" == *"--rss-episode-numbers"* ]]
  [[ "$args" == *"--rss-use-image-as-thumbnail"* ]]
  [[ "$args" == *"--output-folder ."* ]]
  [[ "$args" == *"https://example.com/feed.xml"* ]]
}

@test "passes extra arguments through to studio-pack-generator" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  bats_run_zsh "rss2lunii https://example.com/feed.xml --rss-min-duration 300"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--rss-min-duration 300"* ]]
  [[ "$args" == *"https://example.com/feed.xml"* ]]
}

@test "passes --use-open-ai-tts to studio-pack-generator" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  export OPENAI_API_KEY=test-key
  bats_run_zsh "rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--use-open-ai-tts"* ]]
}

@test "passes --open-ai-api-key with OPENAI_API_KEY env var to studio-pack-generator" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  export OPENAI_API_KEY=test-key-123
  bats_run_zsh "rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--open-ai-api-key test-key-123"* ]]
}

@test "passes --open-ai-voice nova to studio-pack-generator" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  export OPENAI_API_KEY=test-key
  bats_run_zsh "rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--open-ai-voice nova"* ]]
}

@test "does not pass --skip-audio-item-gen to studio-pack-generator" {
  studio-pack-generator() { echo "$@" > "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator

  export OPENAI_API_KEY=test-key
  bats_run_zsh "rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" != *"--skip-audio-item-gen"* ]]
}

@test "deletes existing TTS files when --force-tts is set" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3"
  touch "$BATS_TMP_DIR/mypack/ep2-generated.item.wav"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii --force-tts https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ ! -f "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3" ]]
  [[ ! -f "$BATS_TMP_DIR/mypack/ep2-generated.item.wav" ]]
}

@test "does not delete TTS files when --force-tts is not set" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/args.txt"; }
  bats_mock studio-pack-generator
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3" ]]
}
