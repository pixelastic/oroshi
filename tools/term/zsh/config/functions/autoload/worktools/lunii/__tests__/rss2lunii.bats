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

@test "calls Claude API for episodes without existing images" {
  mkdir -p "$BATS_TMP_DIR/mypack/01 - Episode One"
  mkdir -p "$BATS_TMP_DIR/mypack/02 - Episode Two"

  studio-pack-generator() { :; }
  curl() {
    echo "called" >> "$BATS_TMP_DIR/curl_calls.txt"
    printf '{"content":[{"type":"text","text":"<svg></svg>"}]}'
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  img-resize() { :; }
  bats_mock studio-pack-generator curl svg2png img-resize
  bats_disable_worktree_aware

  export ANTHROPIC_API_KEY=test-anthropic-key
  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/curl_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/curl_calls.txt") -eq 2 ]]
}

@test "skips Claude API for episodes with existing .item.png" {
  mkdir -p "$BATS_TMP_DIR/mypack/01 - Episode One"
  mkdir -p "$BATS_TMP_DIR/mypack/02 - Episode Two"
  touch "$BATS_TMP_DIR/mypack/01 - Episode One/01 - Episode One.item.png"

  studio-pack-generator() { :; }
  curl() {
    echo "called" >> "$BATS_TMP_DIR/curl_calls.txt"
    printf '{"content":[{"type":"text","text":"<svg></svg>"}]}'
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  img-resize() { :; }
  bats_mock studio-pack-generator curl svg2png img-resize
  bats_disable_worktree_aware

  export ANTHROPIC_API_KEY=test-anthropic-key
  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  # Only Episode Two should trigger an API call
  [[ -f "$BATS_TMP_DIR/curl_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/curl_calls.txt") -eq 1 ]]
}

@test "deletes existing images when --force-img is set" {
  mkdir -p "$BATS_TMP_DIR/mypack/01 - Episode One"
  touch "$BATS_TMP_DIR/mypack/01 - Episode One/01 - Episode One.item.png"

  studio-pack-generator() { :; }
  curl() {
    echo "called" >> "$BATS_TMP_DIR/curl_calls.txt"
    printf '{"content":[{"type":"text","text":"<svg></svg>"}]}'
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  img-resize() { :; }
  bats_mock studio-pack-generator curl svg2png img-resize
  bats_disable_worktree_aware

  export ANTHROPIC_API_KEY=test-anthropic-key
  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii --force-img https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  # Image was deleted and regenerated via API
  [[ -f "$BATS_TMP_DIR/curl_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/curl_calls.txt") -eq 1 ]]
}

@test "generates PNG at 320x240 dimensions" {
  mkdir -p "$BATS_TMP_DIR/mypack/01 - Episode One"

  studio-pack-generator() { :; }
  curl() {
    printf '{"content":[{"type":"text","text":"<svg></svg>"}]}'
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  img-resize() { echo "$@" >> "$BATS_TMP_DIR/resize_calls.txt"; }
  bats_mock studio-pack-generator curl svg2png img-resize
  bats_disable_worktree_aware

  export ANTHROPIC_API_KEY=test-anthropic-key
  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/resize_calls.txt" ]]
  [[ "$(cat "$BATS_TMP_DIR/resize_calls.txt")" == *"--no-ratio"* ]]
  [[ "$(cat "$BATS_TMP_DIR/resize_calls.txt")" == *"320x240"* ]]
}

@test "resizes thumbnail to 320x240" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/thumbnail.png"

  studio-pack-generator() { :; }
  img-dimensions() { echo "640x480"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator img-dimensions magick
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/magick_calls.txt" ]]
  local calls="$(cat "$BATS_TMP_DIR/magick_calls.txt")"
  [[ "$calls" == *"-resize 320x240"* ]]
  [[ "$calls" == *"-extent 320x240"* ]]
}

@test "preserves aspect ratio with black padding" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/thumbnail.png"

  studio-pack-generator() { :; }
  img-dimensions() { echo "640x480"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator img-dimensions magick
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/magick_calls.txt")"
  [[ "$calls" == *"-background black"* ]]
  [[ "$calls" == *"-gravity center"* ]]
}

@test "skips resize if thumbnail is already 320x240" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/thumbnail.png"

  studio-pack-generator() { :; }
  img-dimensions() { echo "320x240"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator img-dimensions magick
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  # magick was not called for resize
  [[ ! -f "$BATS_TMP_DIR/magick_calls.txt" ]]
}

@test "full flow calls studio-pack-generator twice" {
  mkdir -p "$BATS_TMP_DIR/mypack"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  bats_mock studio-pack-generator
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/spg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/spg_calls.txt") -eq 2 ]]
}

@test "--force-img and --force-tts are not passed to studio-pack-generator" {
  mkdir -p "$BATS_TMP_DIR/mypack"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  bats_mock studio-pack-generator
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii --force-img --force-tts https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local allCalls="$(cat "$BATS_TMP_DIR/spg_calls.txt")"
  [[ "$allCalls" != *"--force-img"* ]]
  [[ "$allCalls" != *"--force-tts"* ]]
}

@test "does not call Claude API when all episodes have images" {
  mkdir -p "$BATS_TMP_DIR/mypack/01 - Episode One"
  touch "$BATS_TMP_DIR/mypack/01 - Episode One/01 - Episode One.item.png"

  studio-pack-generator() { :; }
  curl() {
    echo "called" >> "$BATS_TMP_DIR/curl_calls.txt"
    printf '{"content":[{"type":"text","text":"<svg></svg>"}]}'
  }
  svg2png() { :; }
  img-resize() { :; }
  bats_mock studio-pack-generator curl svg2png img-resize
  bats_disable_worktree_aware

  export ANTHROPIC_API_KEY=test-anthropic-key
  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ ! -f "$BATS_TMP_DIR/curl_calls.txt" ]]
}
