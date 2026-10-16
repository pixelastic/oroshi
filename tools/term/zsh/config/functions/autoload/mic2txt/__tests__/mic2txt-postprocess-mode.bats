bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-postprocess"
}

@test "outputs none when modes/mic2txt-postprocess does not exist" {
  bats_run_zsh "mic2txt-postprocess-mode"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "none" ]]
}

@test "outputs the file content when modes/mic2txt-postprocess exists" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "midjourney" > "$STORE_FILE"

  bats_run_zsh "mic2txt-postprocess-mode"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "midjourney" ]]
}
