bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "prefixes file with string" {
  touch "$BATS_TMP_DIR/album.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix album.mp3 2024"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/2024 - album.mp3" ]]
  [[ ! -f "$BATS_TMP_DIR/album.mp3" ]]
}

@test "errors on nonexistent file" {
  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix nonexistent.txt 2024"
  [[ "$status" -ne 0 ]]
}

@test "errors when no prefix provided" {
  touch "$BATS_TMP_DIR/file.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-prefix file.txt"
  [[ "$status" -ne 0 ]]
}
