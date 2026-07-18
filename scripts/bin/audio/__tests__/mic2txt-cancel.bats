bats_load_library 'helper'

setup() {
  bats_tmp_dir
  TMP_FOLDER="/dev/shm/oroshi/mic2txt"
}

teardown() {
  rm -f "$TMP_FOLDER/PID" "$TMP_FOLDER/START_TIME" "$TMP_FOLDER/record.wav"
}

# Simulate a recording in progress
setup_recording() {
  mkdir -p "$TMP_FOLDER"
  echo "12345" > "$TMP_FOLDER/PID"
  echo "1234567890.123" > "$TMP_FOLDER/START_TIME"
  echo "fake wav" > "$TMP_FOLDER/record.wav"
}

# --- Recording in progress ---

@test "kills rec process via kill-pid with correct PID" {
  setup_recording
  kill-pid() { echo "$1" > "$BATS_TMP_DIR/killed-pid.txt"; }
  audio-play-oroshi() { :; }
  bats_mock kill-pid audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/killed-pid.txt")" == "12345" ]]
}

@test "removes PID file" {
  setup_recording
  kill-pid() { :; }
  audio-play-oroshi() { :; }
  bats_mock kill-pid audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ ! -f "$TMP_FOLDER/PID" ]]
}

@test "removes START_TIME file" {
  setup_recording
  kill-pid() { :; }
  audio-play-oroshi() { :; }
  bats_mock kill-pid audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ ! -f "$TMP_FOLDER/START_TIME" ]]
}

@test "removes wav file" {
  setup_recording
  kill-pid() { :; }
  audio-play-oroshi() { :; }
  bats_mock kill-pid audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ ! -f "$TMP_FOLDER/record.wav" ]]
}

@test "plays cancel sound" {
  setup_recording
  kill-pid() { :; }
  audio-play-oroshi() { echo "$1" > "$BATS_TMP_DIR/played-sound.txt"; }
  bats_mock kill-pid audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ "$(cat "$BATS_TMP_DIR/played-sound.txt")" == "mic2txt-cancel.mp3" ]]
}

# --- No recording in progress ---

@test "exits without error when no PID file" {
  rm -f "$TMP_FOLDER/PID"

  bats_run_zsh "mic2txt-cancel"
  [[ "$status" -eq 0 ]]
}

@test "does not call kill-pid when no PID file" {
  rm -f "$TMP_FOLDER/PID"
  kill-pid() { echo "called" > "$BATS_TMP_DIR/kill-called.txt"; }
  bats_mock kill-pid

  bats_run_zsh "mic2txt-cancel"
  [[ ! -f "$BATS_TMP_DIR/kill-called.txt" ]]
}

@test "does not play sound when no PID file" {
  rm -f "$TMP_FOLDER/PID"
  audio-play-oroshi() { echo "called" > "$BATS_TMP_DIR/sound-called.txt"; }
  bats_mock audio-play-oroshi

  bats_run_zsh "mic2txt-cancel"
  [[ ! -f "$BATS_TMP_DIR/sound-called.txt" ]]
}
