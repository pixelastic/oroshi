bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/test-mode"
}

@test "outputs default when file does not exist" {
  bats_run_zsh "mode-read test-mode fallback"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "fallback" ]]
}

@test "outputs file content when file exists" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "custom" > "$STORE_FILE"

  bats_run_zsh "mode-read test-mode fallback"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "custom" ]]
}
