bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/test-mode"
}

@test "returns 0 when content is enabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "enabled" > "$STORE_FILE"

  bats_run_zsh "mode-is-enabled test-mode"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when content is disabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "disabled" > "$STORE_FILE"

  bats_run_zsh "mode-is-enabled test-mode"
  [[ "$status" -ne 0 ]]
}

@test "returns 1 when file does not exist" {
  bats_run_zsh "mode-is-enabled test-mode"
  [[ "$status" -ne 0 ]]
}
