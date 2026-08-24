bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-language"
}

@test "writes en when current language is fr" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "fr" > "$STORE_FILE"

  bats_run_zsh "mic2txt-language-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "en" ]]
}

@test "writes fr when current language is en" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "en" > "$STORE_FILE"

  bats_run_zsh "mic2txt-language-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "fr" ]]
}

@test "writes en when file does not exist (default fr toggles to en)" {
  bats_run_zsh "mic2txt-language-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "en" ]]
}
