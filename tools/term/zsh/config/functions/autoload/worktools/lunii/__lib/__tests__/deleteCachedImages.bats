bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "deletes .item.png files in episode subdirs" {
  mkdir -p "$BATS_TMP_DIR/pack/01 - Episode One"
  touch "$BATS_TMP_DIR/pack/01 - Episode One/01 - Episode One.item.png"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedImages.zsh && deleteCachedImages $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/pack/01 - Episode One/01 - Episode One.item.png" ]]
}

@test "deletes .item.jpeg files in episode subdirs" {
  mkdir -p "$BATS_TMP_DIR/pack/01 - Episode One"
  touch "$BATS_TMP_DIR/pack/01 - Episode One/01 - Episode One.item.jpeg"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedImages.zsh && deleteCachedImages $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/pack/01 - Episode One/01 - Episode One.item.jpeg" ]]
}

@test "does not delete non-image files" {
  mkdir -p "$BATS_TMP_DIR/pack/01 - Episode One"
  touch "$BATS_TMP_DIR/pack/01 - Episode One/ep1-generated.item.mp3"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedImages.zsh && deleteCachedImages $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/pack/01 - Episode One/ep1-generated.item.mp3" ]]
}
