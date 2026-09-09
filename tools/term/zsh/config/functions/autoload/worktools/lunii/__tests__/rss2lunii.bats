bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Mock curl that only returns RSS feed
_curl_rss_only() {
  cat <<'BASH'
  curl() {
    printf '<rss><channel><title>mypack</title></channel></rss>'
  }
BASH
}

@test "errors with usage when no arguments provided" {
  bats_run_zsh "rss2lunii"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
  [[ "$output" == *"--output-dir"* ]]
}

@test "calls studio-pack-generator with opinionated defaults" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" == *"--rss-split-length 9999"* ]]
  [[ "$pass1" == *"--rss-episode-numbers"* ]]
  [[ "$pass1" == *"--lang fr"* ]]
  [[ "$pass1" == *"--rss-use-image-as-thumbnail"* ]]
  [[ "$pass1" == *"--output-folder ."* ]]
  [[ "$pass1" == *"https://example.com/feed.xml"* ]]
}

@test "passes --use-open-ai-tts to studio-pack-generator" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" == *"--use-open-ai-tts"* ]]
}

@test "passes --open-ai-api-key with OPENAI_API_KEY env var to studio-pack-generator" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key-123
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" == *"--open-ai-api-key test-key-123"* ]]
}

@test "passes --lang fr to studio-pack-generator" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" == *"--lang fr"* ]]
}

@test "passes --open-ai-voice nova to studio-pack-generator" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" == *"--open-ai-voice nova"* ]]
}

@test "does not pass --skip-audio-item-gen to first pass" {
  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local pass1=$(sed -n '1p' "$BATS_TMP_DIR/spg_calls.txt")
  [[ "$pass1" != *"--skip-audio-item-gen"* ]]
}

@test "deletes existing TTS files when --force-tts is set" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3"
  touch "$BATS_TMP_DIR/mypack/ep2-generated.item.wav"

  studio-pack-generator() { :; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
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

  studio-pack-generator() { :; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/mypack/ep1-generated.item.mp3" ]]
}

@test "--force-generate-episode-thumbnails deletes PNGs and regenerates via SVG" {
  local episodesDir="$BATS_TMP_DIR/mypack/Choose your story"
  mkdir -p "$episodesDir"
  echo "unique A" > "$episodesDir/20240101 Episode One.item.jpeg"
  echo "unique B" > "$episodesDir/20240102 Episode Two.item.jpeg"
  touch "$episodesDir/20240101 Episode One.item.png"
  touch "$episodesDir/20240102 Episode Two.item.png"

  studio-pack-generator() { :; }
  eval "$(_curl_rss_only)"
  txt2svg() {
    echo "called" >> "$BATS_TMP_DIR/txt2svg_calls.txt"
    local outputPath=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output) outputPath="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    echo "<svg></svg>" > "$outputPath"
  }
  svg2png() {
    for f in "$@"; do touch "${f%.svg}.png"; done
  }
  resizeToLunii() {
    local noExt="${1%.*}"
    touch "${noExt}.png"
  }
  bats_mock studio-pack-generator curl txt2svg svg2png resizeToLunii
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-openai-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii --force-generate-episode-thumbnails https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  # txt2svg called for all episodes despite unique hashes
  [[ -f "$BATS_TMP_DIR/txt2svg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/txt2svg_calls.txt") -eq 2 ]]
}

@test "resizes thumbnail to 320x240" {
  mkdir -p "$BATS_TMP_DIR/mypack"
  touch "$BATS_TMP_DIR/mypack/thumbnail.png"

  studio-pack-generator() { :; }
  eval "$(_curl_rss_only)"
  img-dimensions() { echo "640x480"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator curl img-dimensions magick
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
  eval "$(_curl_rss_only)"
  img-dimensions() { echo "640x480"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator curl img-dimensions magick
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
  eval "$(_curl_rss_only)"
  img-dimensions() { echo "320x240"; }
  magick() { echo "$@" >> "$BATS_TMP_DIR/magick_calls.txt"; }
  bats_mock studio-pack-generator curl img-dimensions magick
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ ! -f "$BATS_TMP_DIR/magick_calls.txt" ]]
}

@test "full flow calls studio-pack-generator twice" {
  mkdir -p "$BATS_TMP_DIR/mypack"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/spg_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/spg_calls.txt") -eq 2 ]]
}

@test "--output-dir runs pipeline inside the target directory" {
  local targetDir="$BATS_TMP_DIR/podcasts"
  mkdir -p "$targetDir"

  studio-pack-generator() { pwd >> "$BATS_TMP_DIR/spg_cwd.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "rss2lunii --output-dir $targetDir https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  # studio-pack-generator was called from inside the target directory
  local cwd="$(head -1 "$BATS_TMP_DIR/spg_cwd.txt")"
  [[ "$cwd" == "$targetDir" ]]
}

@test "custom flags are not passed to studio-pack-generator" {
  mkdir -p "$BATS_TMP_DIR/mypack"

  studio-pack-generator() { echo "$@" >> "$BATS_TMP_DIR/spg_calls.txt"; }
  eval "$(_curl_rss_only)"
  bats_mock studio-pack-generator curl
  bats_disable_worktree_aware

  export OPENAI_API_KEY=test-key
  bats_run_zsh "cd $BATS_TMP_DIR && rss2lunii --force-generate-episode-thumbnails --force-tts https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local allCalls="$(cat "$BATS_TMP_DIR/spg_calls.txt")"
  [[ "$allCalls" != *"--force-generate-episode-thumbnails"* ]]
  [[ "$allCalls" != *"--force-tts"* ]]
}

