bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "transliterates accented characters" {
  touch "$BATS_TMP_DIR/résumé.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'résumé.txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/resume.txt" ]]
}

@test "removes forbidden characters" {
  touch "$BATS_TMP_DIR/song:title.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'song:title.mp3'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/songtitle.mp3" ]]
}

@test "removes curly quotes" {
  local curly=$'\u2019'
  touch "$BATS_TMP_DIR/it${curly}s.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'it${curly}s.txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/its.txt" ]]
}

@test "preserves spaces" {
  touch "$BATS_TMP_DIR/hello world.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'hello world.txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/hello world.txt" ]]
}

@test "strips trailing space" {
  touch "$BATS_TMP_DIR/trailing .txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'trailing .txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/trailing.txt" ]]
}

@test "replaces remaining special chars with underscore" {
  touch "$BATS_TMP_DIR/hello!world.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'hello!world.txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/hello_world.txt" ]]
}

@test "handles multiple files" {
  touch "$BATS_TMP_DIR/café.txt" "$BATS_TMP_DIR/naïve.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean 'café.txt' 'naïve.txt'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/cafe.txt" ]]
  [[ -f "$BATS_TMP_DIR/naive.txt" ]]
}

@test "skips already-clean filenames" {
  touch "$BATS_TMP_DIR/clean_file.txt"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-clean clean_file.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/clean_file.txt" ]]
}
