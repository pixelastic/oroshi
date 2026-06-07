bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../sidequest-end"
}

teardown() {
  bats_cleanup
}

@test "no argument: exits with error" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "file does not exist: exits with error" {
  bats_run_zsh "$CURRENT" "$BATS_TMP_DIR/nonexistent.md"
  [ "$status" -eq 1 ]
}

@test "valid file: calls clipboard-write with @<filepath>" {
  file="$BATS_TMP_DIR/sidequest.md"
  touch "$file"
  clipboard-write() { cat >"$BATS_TMP_DIR/clipboard-in"; }
  bats_mock clipboard-write

  bats_run_zsh "$CURRENT" "$file"

  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/clipboard-in")" == "@${file}" ]]
}
