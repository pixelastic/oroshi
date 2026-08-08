bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "renames files with zero-padded sequential numbers" {
  touch "$BATS_TMP_DIR/alpha.jpg" "$BATS_TMP_DIR/beta.jpg" "$BATS_TMP_DIR/gamma.jpg"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-sequential alpha.jpg beta.jpg gamma.jpg"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/0000.jpg" ]]
  [[ -f "$BATS_TMP_DIR/0001.jpg" ]]
  [[ -f "$BATS_TMP_DIR/0002.jpg" ]]
}

@test "preserves file extensions" {
  touch "$BATS_TMP_DIR/photo.png"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-sequential photo.png"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/0000.png" ]]
}
