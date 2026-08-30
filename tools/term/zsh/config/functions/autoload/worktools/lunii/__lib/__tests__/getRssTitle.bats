bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "extracts title from RSS feed" {
  curl() {
    printf '<rss><channel><title>Mon Super Podcast</title></channel></rss>'
  }
  bats_mock curl

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/getRssTitle.zsh && getRssTitle https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Mon Super Podcast" ]]
}

@test "handles titles with special characters" {
  curl() {
    printf '<rss><channel><title>L'\''émission de Lulu &amp; Co</title></channel></rss>'
  }
  bats_mock curl

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/getRssTitle.zsh && getRssTitle https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "L'émission de Lulu & Co" ]]
}

@test "passes URL to curl" {
  curl() {
    echo "$@" > "$BATS_TMP_DIR/curl_args.txt"
    printf '<rss><channel><title>Test</title></channel></rss>'
  }
  bats_mock curl
  bats_disable_worktree_aware

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "cd $BATS_TMP_DIR && source $libDir/getRssTitle.zsh && getRssTitle https://example.com/feed.xml"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/curl_args.txt")"
  [[ "$args" == *"--silent"* ]]
  [[ "$args" == *"https://example.com/feed.xml"* ]]
}
