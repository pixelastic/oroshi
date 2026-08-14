bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/audio/__lib/wav2txt-groq'"
}

# --- isFileTooBig ---

@test "isFileTooBig returns true for files >= 25MB" {
  truncate -s 26214400 "$BATS_TMP_DIR/big.wav"
  bats_run_zsh "$sourcePrefix && isFileTooBig '$BATS_TMP_DIR/big.wav'"
  [[ "$status" -eq 0 ]]
}

@test "isFileTooBig returns false for files < 25MB" {
  truncate -s 1000 "$BATS_TMP_DIR/small.wav"
  bats_run_zsh "$sourcePrefix && isFileTooBig '$BATS_TMP_DIR/small.wav'"
  [[ "$status" -ne 0 ]]
}

# --- transcribeFile ---

@test "transcribeFile outputs plain text from a single curl call" {
  curl() { echo "bonjour le monde"; }
  bats_mock curl

  touch "$BATS_TMP_DIR/recording.wav"
  bats_run_zsh "$sourcePrefix && transcribeFile '$BATS_TMP_DIR/recording.wav'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "bonjour le monde" ]]
}

# --- splitAndTranscribe ---

@test "splitAndTranscribe splits, transcribes each chunk, concatenates" {
  # Mock audio-split to create fake parts and print their paths
  audio-split() {
    touch "$BATS_TMP_DIR/recording-part1.wav"
    touch "$BATS_TMP_DIR/recording-part2.wav"
    echo "$BATS_TMP_DIR/recording-part1.wav"
    echo "$BATS_TMP_DIR/recording-part2.wav"
  }
  # Mock curl to return different text per chunk
  curl() {
    for arg in "$@"; do
      [[ "$arg" == file=@*part1* ]] && { echo "première partie"; return; }
      [[ "$arg" == file=@*part2* ]] && { echo "deuxième partie"; return; }
    done
  }
  bats_mock audio-split curl

  touch "$BATS_TMP_DIR/recording.wav"
  bats_run_zsh "$sourcePrefix && splitAndTranscribe '$BATS_TMP_DIR/recording.wav'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "première partie deuxième partie" ]]

  # Verify temp chunk files were cleaned up
  [[ ! -f "$BATS_TMP_DIR/recording-part1.wav" ]]
  [[ ! -f "$BATS_TMP_DIR/recording-part2.wav" ]]
}
