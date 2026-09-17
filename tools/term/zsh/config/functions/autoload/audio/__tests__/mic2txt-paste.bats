bats_load_library 'helper'

setup() {
  bats_tmp_dir
  TMP_FOLDER="/dev/shm/oroshi/mic2txt"
  mkdir -p "$TMP_FOLDER"
  echo "hello world" > "$TMP_FOLDER/transcription.txt"

  # Default mocks: no kitty target, autosubmit disabled
  focus-insert() { echo "$1" > "$BATS_TMP_DIR/inserted.txt"; }
  clipboard-write() { echo "$1" > "$BATS_TMP_DIR/clipboard.txt"; }
  kitty-window-paste() { echo "$@" > "$BATS_TMP_DIR/kitty-paste-args.txt"; }
  kitty-window-send-text() { printf '%s' "$*" > "$BATS_TMP_DIR/kitty-send-args.txt"; }
  mic2txt-autosubmit-mode-is-enabled() { return 1; }
  better-ydotool() { echo "$@" > "$BATS_TMP_DIR/ydotool-args.txt"; }
  sleep() { :; }
  bats_mock focus-insert clipboard-write kitty-window-paste kitty-window-send-text mic2txt-autosubmit-mode-is-enabled better-ydotool sleep
}

teardown() {
  rm -f "$TMP_FOLDER/transcription.txt" "$TMP_FOLDER/TARGET_WINDOW_ID"
}

# --- File missing ---

@test "exits 0 when file missing" {
  rm -f "$TMP_FOLDER/transcription.txt"

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
}

@test "does not call focus-insert when file missing" {
  rm -f "$TMP_FOLDER/transcription.txt"

  bats_run_zsh "mic2txt-paste"
  [[ ! -f "$BATS_TMP_DIR/inserted.txt" ]]
}

# --- Kitty target exists ---

@test "calls clipboard-write then kitty-window-paste with correct window ID" {
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/clipboard.txt")" == "hello world" ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-paste-args.txt")" == "42" ]]
}

@test "does not call focus-insert when kitty target exists" {
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"

  bats_run_zsh "mic2txt-paste"
  [[ ! -f "$BATS_TMP_DIR/inserted.txt" ]]
}

# --- Kitty target with autosubmit ---

@test "calls kitty-window-send-text with carriage return after paste when autosubmit enabled" {
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"
  mic2txt-autosubmit-mode-is-enabled() { return 0; }
  bats_mock mic2txt-autosubmit-mode-is-enabled

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-send-args.txt")" == "42 \r" ]]
}

# --- No kitty target ---

@test "calls focus-insert with content when no kitty target" {
  rm -f "$TMP_FOLDER/TARGET_WINDOW_ID"

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/inserted.txt")" == "hello world" ]]
}

@test "does not call kitty-window-paste when no kitty target" {
  rm -f "$TMP_FOLDER/TARGET_WINDOW_ID"

  bats_run_zsh "mic2txt-paste"
  [[ ! -f "$BATS_TMP_DIR/kitty-paste-args.txt" ]]
}

# --- No kitty target with autosubmit ---

@test "calls better-ydotool after focus-insert when autosubmit enabled and no kitty target" {
  rm -f "$TMP_FOLDER/TARGET_WINDOW_ID"
  mic2txt-autosubmit-mode-is-enabled() { return 0; }
  bats_mock mic2txt-autosubmit-mode-is-enabled

  bats_run_zsh "mic2txt-paste"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/ydotool-args.txt")" == "key 28:1 28:0" ]]
}
