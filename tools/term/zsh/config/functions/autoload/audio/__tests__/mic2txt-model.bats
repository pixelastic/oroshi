bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  STORE_FILE="$BATS_TMP_DIR/modes/mic2txt-model"
}

@test "outputs openai when modes/mic2txt-model does not exist" {
  bats_run_zsh "mic2txt-model"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "openai" ]]
}

@test "outputs the file content when modes/mic2txt-model exists" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "groq" > "$STORE_FILE"

  bats_run_zsh "mic2txt-model"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "groq" ]]
}
