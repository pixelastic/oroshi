bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-language"
}

@test "outputs fr when modes/mic2txt-language does not exist" {
  bats_run_zsh "mic2txt-language"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "fr" ]]
}

@test "outputs en when modes/mic2txt-language contains en" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "en" > "$STORE_FILE"

  bats_run_zsh "mic2txt-language"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "en" ]]
}

@test "outputs fr when modes/mic2txt-language contains fr" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "fr" > "$STORE_FILE"

  bats_run_zsh "mic2txt-language"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "fr" ]]
}
