bats_load_library 'helper'

setup() {
  bats_tmp_dir
  TMP_FOLDER="/dev/shm/oroshi/mic2txt"
}

teardown() {
  rm -f "$TMP_FOLDER/transcription.txt"
}

# --- File present with content ---

@test "calls focus-insert with file content" {
  mkdir -p "$TMP_FOLDER"
  echo "hello world" > "$TMP_FOLDER/transcription.txt"
  focus-insert() { echo "$1" > "$BATS_TMP_DIR/inserted.txt"; }
  bats_mock focus-insert

  bats_run_zsh "mic2txt-paste"
  [[ "$(cat "$BATS_TMP_DIR/inserted.txt")" == "hello world" ]]
}

@test "exits 0 when file present" {
  mkdir -p "$TMP_FOLDER"
  echo "hello world" > "$TMP_FOLDER/transcription.txt"
  focus-insert() { :; }
  bats_mock focus-insert

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
}

# --- File missing ---

@test "exits 0 when file missing" {
  rm -f "$TMP_FOLDER/transcription.txt"

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
}

@test "does not call focus-insert when file missing" {
  rm -f "$TMP_FOLDER/transcription.txt"
  focus-insert() { echo "called" > "$BATS_TMP_DIR/focus-called.txt"; }
  bats_mock focus-insert

  bats_run_zsh "mic2txt-paste"
  [[ ! -f "$BATS_TMP_DIR/focus-called.txt" ]]
}
