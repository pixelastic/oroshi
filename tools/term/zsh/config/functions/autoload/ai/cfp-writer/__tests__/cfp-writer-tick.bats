bats_load_library 'helper'

setup() {
  bats_tmp_dir
  DRAFT_PATH="$BATS_TMP_DIR/draft.md"
  printf '%s' "hello world" > "$DRAFT_PATH"
}

@test "copies draft file content to clipboard" {
  clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard.txt"; }
  bats_mock clipboard-write

  bats_run_zsh "cfp-writer-tick '$DRAFT_PATH'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/clipboard.txt")" = "hello world" ]]
}

@test "fails without argument" {
  bats_run_zsh "cfp-writer-tick"
  [[ "$status" -eq 1 ]]
}

@test "fails if file does not exist" {
  bats_run_zsh "cfp-writer-tick '/nonexistent/path.md'"
  [[ "$status" -eq 1 ]]
}
