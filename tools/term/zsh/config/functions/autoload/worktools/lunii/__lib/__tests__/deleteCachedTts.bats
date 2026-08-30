bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "deletes generated .mp3 TTS files" {
  mkdir -p "$BATS_TMP_DIR/pack"
  touch "$BATS_TMP_DIR/pack/ep1-generated.item.mp3"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedTts.zsh && deleteCachedTts $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/pack/ep1-generated.item.mp3" ]]
}

@test "deletes generated .wav TTS files" {
  mkdir -p "$BATS_TMP_DIR/pack"
  touch "$BATS_TMP_DIR/pack/ep2-generated.item.wav"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedTts.zsh && deleteCachedTts $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/pack/ep2-generated.item.wav" ]]
}

@test "does not delete non-TTS files" {
  mkdir -p "$BATS_TMP_DIR/pack"
  touch "$BATS_TMP_DIR/pack/episode.mp3"

  local libDir
  libDir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  bats_run_zsh "source $libDir/deleteCachedTts.zsh && deleteCachedTts $BATS_TMP_DIR/pack"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/pack/episode.mp3" ]]
}
