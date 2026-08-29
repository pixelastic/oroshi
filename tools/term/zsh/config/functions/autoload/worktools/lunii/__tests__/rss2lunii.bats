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
