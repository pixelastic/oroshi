bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FIXTURE="$BATS_TEST_DIRNAME/fixtures/simple.epub"
  CURRENT="$BATS_TEST_DIRNAME/../epub2md"
  cp "$FIXTURE" "$BATS_TMP_DIR/simple.epub"
}

teardown() {
  bats_cleanup
}

@test "converts to .md" {
  bats_run_zsh "$CURRENT" "$BATS_TMP_DIR/simple.epub"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/simple.md" ]
  [ ! -f "$BATS_TMP_DIR/simple.txt" ]
  grep -q "Simple Test Book" "$BATS_TMP_DIR/simple.md"
}

@test "processes multiple files" {
  cp "$FIXTURE" "$BATS_TMP_DIR/other.epub"
  bats_run_zsh "$CURRENT" "$BATS_TMP_DIR/simple.epub" "$BATS_TMP_DIR/other.epub"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/simple.md" ]
  [ -f "$BATS_TMP_DIR/other.md" ]
}
