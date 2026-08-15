bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
  MODEL_DIR="$BATS_TMP_DIR/mic2txt"
  MODEL_FILE="$MODEL_DIR/model"
  mkdir -p "$MODEL_DIR"
}

@test "openai toggles to parakeet" {
  echo "openai" > "$MODEL_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$MODEL_FILE")" == "parakeet" ]]
}

@test "parakeet toggles to groq" {
  echo "parakeet" > "$MODEL_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$MODEL_FILE")" == "groq" ]]
}

@test "groq toggles to openai" {
  echo "groq" > "$MODEL_FILE"

  bats_run_zsh "mic2txt-model-toggle"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$MODEL_FILE")" == "openai" ]]
}
