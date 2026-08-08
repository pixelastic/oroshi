bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "capitalizes each word" {
  touch "$BATS_TMP_DIR/hello world.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-capitalize 'hello world.mp3'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/Hello World.mp3" ]]
}

@test "capitalizes indexed filename title" {
  touch "$BATS_TMP_DIR/01 - the last of us.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-capitalize '01 - the last of us.mp3'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/01 - The Last Of Us.mp3" ]]
}

@test "handles multiple files" {
  touch "$BATS_TMP_DIR/first song.mp3" "$BATS_TMP_DIR/second song.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-capitalize 'first song.mp3' 'second song.mp3'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/First Song.mp3" ]]
  [[ -f "$BATS_TMP_DIR/Second Song.mp3" ]]
}

@test "skips already-capitalized files" {
  touch "$BATS_TMP_DIR/Already Good.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-capitalize 'Already Good.mp3'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/Already Good.mp3" ]]
}

@test "single word file" {
  touch "$BATS_TMP_DIR/intro.mp3"

  bats_run_zsh "cd $BATS_TMP_DIR && rename-capitalize intro.mp3"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/Intro.mp3" ]]
}
