bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-slack"
}

@test "returns 0 when modes/mic2txt-slack contains enabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "enabled" > "$STORE_FILE"

  bats_run_zsh "mic2txt-slack-mode-is-enabled"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when modes/mic2txt-slack contains disabled" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "disabled" > "$STORE_FILE"

  bats_run_zsh "mic2txt-slack-mode-is-enabled"
  [[ "$status" -ne 0 ]]
}

@test "returns 1 when modes/mic2txt-slack does not exist" {
  bats_run_zsh "mic2txt-slack-mode-is-enabled"
  [[ "$status" -ne 0 ]]
}
