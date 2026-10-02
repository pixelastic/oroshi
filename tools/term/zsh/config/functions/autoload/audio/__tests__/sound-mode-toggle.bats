bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/sound"
}

@test "writes enabled when file does not exist" {
  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "enabled" ]]
}

@test "writes disabled when file contains enabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "enabled" > "$STORE_FILE"

  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "disabled" ]]
}

@test "writes enabled when file contains disabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "disabled" > "$STORE_FILE"

  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "enabled" ]]
}

@test "creates modes/ directory if missing" {
  bats_run_zsh "sound-mode-toggle"
  [[ "$status" -eq 0 ]]
  [[ -d "$BATS_TMP_DIR/modes" ]]
}
