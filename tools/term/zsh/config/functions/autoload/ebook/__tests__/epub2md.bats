bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FIXTURE="$BATS_TEST_DIRNAME/fixtures/simple.epub"
  cp "$FIXTURE" "$BATS_TMP_DIR/simple.epub"
}

@test "converts to .md" {
  bats_run_zsh "epub2md $BATS_TMP_DIR/simple.epub"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/simple.md" ]
  [ ! -f "$BATS_TMP_DIR/simple.txt" ]
  grep -q "Simple Test Book" "$BATS_TMP_DIR/simple.md"
}

@test "processes multiple files" {
  cp "$FIXTURE" "$BATS_TMP_DIR/other.epub"
  bats_run_zsh "epub2md $BATS_TMP_DIR/simple.epub $BATS_TMP_DIR/other.epub"
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/simple.md" ]
  [ -f "$BATS_TMP_DIR/other.md" ]
}
