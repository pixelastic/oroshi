bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

_lib_dir() {
  echo "${BATS_TEST_DIRNAME}/../__lib"
}

@test "replaces 0-item.mp3 with French asset" {
  mkdir -p "$BATS_TMP_DIR/mypack/Choose your story"
  echo "english" > "$BATS_TMP_DIR/mypack/Choose your story/0-item.mp3"

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/localizeEpisodesFolder.zsh && localizeEpisodesFolder $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  [[ "$(cat "$BATS_TMP_DIR/mypack/Choose your story/0-item.mp3")" != "english" ]]
}

@test "replaces 0-item.png with French asset" {
  mkdir -p "$BATS_TMP_DIR/mypack/Choose your story"
  echo "english" > "$BATS_TMP_DIR/mypack/Choose your story/0-item.png"

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/localizeEpisodesFolder.zsh && localizeEpisodesFolder $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]

  [[ "$(cat "$BATS_TMP_DIR/mypack/Choose your story/0-item.png")" != "english" ]]
}

@test "skips when episodes folder does not exist" {
  mkdir -p "$BATS_TMP_DIR/mypack"

  local libDir="$(_lib_dir)"
  bats_run_zsh "source $libDir/localizeEpisodesFolder.zsh && localizeEpisodesFolder $BATS_TMP_DIR/mypack"
  [[ "$status" -eq 0 ]]
}
