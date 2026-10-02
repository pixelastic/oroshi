bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/sound"
}

@test "returns 0 when modes/sound contains enabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "enabled" > "$STORE_FILE"

  bats_run_zsh "sound-mode-is-enabled"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when modes/sound contains disabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "disabled" > "$STORE_FILE"

  bats_run_zsh "sound-mode-is-enabled"
  [[ "$status" -ne 0 ]]
}

@test "returns 1 when modes/sound does not exist" {
  bats_run_zsh "sound-mode-is-enabled"
  [[ "$status" -ne 0 ]]
}
