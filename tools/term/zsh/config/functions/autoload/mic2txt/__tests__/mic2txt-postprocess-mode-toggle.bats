bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-postprocess"
}

@test "none toggles to midjourney" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "none" > "$STORE_FILE"

  bats_run_zsh "mic2txt-postprocess-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "midjourney" ]]
}

@test "midjourney toggles to none" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "midjourney" > "$STORE_FILE"

  bats_run_zsh "mic2txt-postprocess-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "none" ]]
}

@test "writes midjourney when file does not exist (default none toggles to midjourney)" {
  bats_run_zsh "mic2txt-postprocess-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "midjourney" ]]
}
