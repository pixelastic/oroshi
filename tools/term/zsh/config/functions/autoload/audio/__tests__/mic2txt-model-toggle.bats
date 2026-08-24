bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-model"
}

@test "openai toggles to parakeet" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "openai" > "$STORE_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "parakeet" ]]
}

@test "parakeet toggles to groq" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "parakeet" > "$STORE_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "groq" ]]
}

@test "groq toggles to openai" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "groq" > "$STORE_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "openai" ]]
}

@test "writes parakeet when file does not exist (default openai toggles to parakeet)" {
  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$STORE_FILE")" == "parakeet" ]]
}
