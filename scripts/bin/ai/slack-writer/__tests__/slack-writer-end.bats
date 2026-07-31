bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "passes argument text to clipboard-write" {
  clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard.txt"; }
  bats_mock clipboard-write

  bats_run_zsh "slack-writer-end 'hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/clipboard.txt")" = "hello world" ]]
}

@test "passes stdin text to clipboard-write" {
  clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard.txt"; }
  bats_mock clipboard-write

  bats_run_zsh "echo 'hello world' | slack-writer-end"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/clipboard.txt")" = "hello world" ]]
}
