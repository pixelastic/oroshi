bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "wraps a file in a same-name directory" {
  touch "$BATS_TMP_DIR/song.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-to-directory song.mp3"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/song/song.mp3" ]]
}

@test "handles multiple files" {
  touch "$BATS_TMP_DIR/a.txt" "$BATS_TMP_DIR/b.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-to-directory a.txt b.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/a/a.txt" ]]
  [[ -f "$BATS_TMP_DIR/b/b.txt" ]]
}

@test "skips nonexistent files" {
  bats_run_zsh "cd $BATS_TMP_DIR && rename-to-directory nonexistent.txt"
  [[ "$status" -eq 0 ]]
  [[ ! -d "$BATS_TMP_DIR/nonexistent" ]]
}

@test "reuses existing directory" {
  mkdir "$BATS_TMP_DIR/song"
  touch "$BATS_TMP_DIR/song.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-to-directory song.mp3"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/song/song.mp3" ]]
}
