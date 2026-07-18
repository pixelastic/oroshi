bats_load_library 'helper'

setup() {
  bats_tmp_dir
  TMP_FOLDER="/dev/shm/oroshi/mic2txt"
  mkdir -p "$TMP_FOLDER"
}

teardown() {
  rm -f "$TMP_FOLDER/PID" "$TMP_FOLDER/START_TIME" "$TMP_FOLDER/record.wav"
}

# --- Starting a recording ---

@test "creates START_TIME file when starting a recording" {
  rm -f "$TMP_FOLDER/PID"
  rec() { :; }
  bats_mock rec

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP_FOLDER/START_TIME" ]]
}

# --- Stopping with elapsed < 2 seconds ---

@test "calls mic2txt-cancel when elapsed < 2s" {
  echo "12345" > "$TMP_FOLDER/PID"
  mic2txt-cancel() { echo "called" > "$BATS_TMP_DIR/cancel-called.txt"; }
  bats_mock mic2txt-cancel

  bats_run_zsh "zmodload zsh/datetime; echo \$EPOCHREALTIME > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/cancel-called.txt" ]]
}

@test "does not call transcription binary when elapsed < 2s" {
  echo "12345" > "$TMP_FOLDER/PID"
  mic2txt-cancel() { :; }
  bats_mock mic2txt-cancel

  echo '#!/bin/sh' > "$BATS_TMP_DIR/fake-wav2txt"
  echo "touch $BATS_TMP_DIR/wav2txt-called.txt" >> "$BATS_TMP_DIR/fake-wav2txt"
  chmod +x "$BATS_TMP_DIR/fake-wav2txt"

  bats_run_zsh "zmodload zsh/datetime; echo \$EPOCHREALTIME > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt $BATS_TMP_DIR/fake-wav2txt"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/wav2txt-called.txt" ]]
}

# --- Stopping with elapsed >= 2 seconds ---

@test "does not call mic2txt-cancel when elapsed >= 2s" {
  echo "12345" > "$TMP_FOLDER/PID"
  mic2txt-cancel() { echo "called" > "$BATS_TMP_DIR/cancel-called.txt"; }
  kill-pid() { :; }
  audio-play-oroshi() { :; }
  mic2txt-language() { echo "fr"; }
  mic2txt-slack-mode-is-enabled() { return 1; }
  mic2txt-autosubmit-mode-is-enabled() { return 1; }
  focus-insert() { :; }
  sleep() { :; }
  bats_mock mic2txt-cancel kill-pid audio-play-oroshi mic2txt-language mic2txt-slack-mode-is-enabled mic2txt-autosubmit-mode-is-enabled focus-insert sleep

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/cancel-called.txt" ]]
}

@test "proceeds with transcription when elapsed >= 2s" {
  echo "12345" > "$TMP_FOLDER/PID"
  kill-pid() { :; }
  audio-play-oroshi() { :; }
  mic2txt-language() { echo "fr"; }
  mic2txt-slack-mode-is-enabled() { return 1; }
  mic2txt-autosubmit-mode-is-enabled() { return 1; }
  focus-insert() { echo "$1" > "$BATS_TMP_DIR/inserted.txt"; }
  sleep() { :; }
  bats_mock kill-pid audio-play-oroshi mic2txt-language mic2txt-slack-mode-is-enabled mic2txt-autosubmit-mode-is-enabled focus-insert sleep

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/inserted.txt" ]]
}
