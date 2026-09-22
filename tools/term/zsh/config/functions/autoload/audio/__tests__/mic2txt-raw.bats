bats_load_library 'helper'

# Global mocks: all modes enabled, language fr, all side effects neutralized
setup() {
  bats_tmp_dir
  TMP_FOLDER="$BATS_TMP_DIR/mic2txt"
  mkdir -p "$TMP_FOLDER"
  bats_mock_env MOCK_MIC2TXT_TMP_FOLDER "$TMP_FOLDER"

  local colorsJson="$OROSHI_ROOT/tools/term/zsh/config/theming/dist/colors.json"
  COLOR_RECORDING="$(jq -r '.["kitty-mic2txt-recording"].hex' "$colorsJson")"
  COLOR_STOPPED="$(jq -r '.["kitty-mic2txt-stopped"].hex' "$colorsJson")"
  COLOR_PROCESSING="$(jq -r '.["kitty-mic2txt-processing"].hex' "$colorsJson")"

  rec() { :; }
  process-kill() { :; }
  audio-play-oroshi() { :; }
  mic2txt-language() { echo "fr"; }
  mic2txt-slack-mode-is-enabled() { return 0; }
  mic2txt-autosubmit-mode-is-enabled() { return 0; }
  mic2txt-cancel() { :; }
  mic2txt-paste() { :; }
  focus-insert() { :; }
  txt2slack() { echo "$1"; }
  better-ydotool() { :; }
  sleep() { :; }
  kitty-os-window-is-focused() { return 1; }
  kitty-window-id() { echo "0"; }
  kitty-window-highlight() { :; }
  kitty-window-highlight-reset() { :; }
  bats_mock rec process-kill audio-play-oroshi mic2txt-language mic2txt-slack-mode-is-enabled mic2txt-autosubmit-mode-is-enabled mic2txt-cancel mic2txt-paste focus-insert txt2slack better-ydotool sleep kitty-os-window-is-focused kitty-window-id kitty-window-highlight kitty-window-highlight-reset
}


# --- Starting a recording ---

@test "creates START_TIME file when starting a recording" {
  rm -f "$TMP_FOLDER/PID"

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP_FOLDER/START_TIME" ]]
}

# --- Capturing target window at start ---

@test "saves kitty window ID when kitty is focused at start" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 0; }
  kitty-window-id() { echo "42"; }
  kitty-window-highlight() { echo "$@" > "$BATS_TMP_DIR/highlight-args"; }
  bats_mock kitty-os-window-is-focused kitty-window-id kitty-window-highlight

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$TMP_FOLDER/TARGET_WINDOW_ID")" == "42" ]]
}

@test "highlights kitty window yellow when kitty is focused at start" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 0; }
  kitty-window-id() { echo "42"; }
  kitty-window-highlight() { echo "$@" > "$BATS_TMP_DIR/highlight-args"; }
  bats_mock kitty-os-window-is-focused kitty-window-id kitty-window-highlight

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/highlight-args")" == "--window 42 $COLOR_RECORDING" ]]
}

@test "does not create TARGET_WINDOW_ID when kitty is not focused at start" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 1; }
  kitty-window-highlight() { echo "called" > "$BATS_TMP_DIR/highlight-called"; }
  bats_mock kitty-os-window-is-focused kitty-window-highlight

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$TMP_FOLDER/TARGET_WINDOW_ID" ]]
}

@test "does not highlight when kitty is not focused at start" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 1; }
  kitty-window-highlight() { echo "called" > "$BATS_TMP_DIR/highlight-called"; }
  bats_mock kitty-os-window-is-focused kitty-window-highlight

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/highlight-called" ]]
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
  bats_mock mic2txt-cancel

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/cancel-called.txt" ]]
}

@test "proceeds with transcription when elapsed >= 2s" {
  echo "12345" > "$TMP_FOLDER/PID"

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
}

@test "writes transcription to transcription.txt" {
  echo "12345" > "$TMP_FOLDER/PID"

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP_FOLDER/transcription.txt" ]]
}

@test "calls mic2txt-paste instead of focus-insert" {
  echo "12345" > "$TMP_FOLDER/PID"
  mic2txt-paste() { echo "called" > "$BATS_TMP_DIR/paste-called.txt"; }
  focus-insert() { echo "called" > "$BATS_TMP_DIR/focus-called.txt"; }
  bats_mock mic2txt-paste focus-insert

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/paste-called.txt" ]]
  [[ ! -f "$BATS_TMP_DIR/focus-called.txt" ]]
}

# --- Processing highlight on stop ---

@test "stop: switches highlight to stopped color then processing color" {
  echo "12345" > "$TMP_FOLDER/PID"
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"
  kitty-window-highlight() { echo "$@" >> "$BATS_TMP_DIR/highlight-calls"; }
  bats_mock kitty-window-highlight

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/highlight-calls")"
  [[ "$(sed -n '1p' <<< "$calls")" == "--window 42 $COLOR_STOPPED" ]]
  [[ "$(sed -n '2p' <<< "$calls")" == "--window 42 $COLOR_PROCESSING" ]]
}

@test "stop: does not switch highlight when no TARGET_WINDOW_ID" {
  echo "12345" > "$TMP_FOLDER/PID"
  rm -f "$TMP_FOLDER/TARGET_WINDOW_ID"
  kitty-window-highlight() { echo "$@" >> "$BATS_TMP_DIR/highlight-calls"; }
  bats_mock kitty-window-highlight

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/highlight-calls" ]]
}

# --- Cleanup on stop with kitty target ---

@test "stop: does not call highlight-reset directly (delegated to mic2txt-paste)" {
  echo "12345" > "$TMP_FOLDER/PID"
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"
  kitty-window-highlight-reset() { echo "called" > "$BATS_TMP_DIR/reset-called.txt"; }
  bats_mock kitty-window-highlight-reset

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/reset-called.txt" ]]
}

@test "stop: removes TARGET_WINDOW_ID file" {
  echo "12345" > "$TMP_FOLDER/PID"
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"
  kitty-window-highlight-reset() { :; }
  bats_mock kitty-window-highlight-reset

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$TMP_FOLDER/TARGET_WINDOW_ID" ]]
}

# --- Cleanup on stop without kitty target ---

@test "stop: does not call highlight-reset when no TARGET_WINDOW_ID" {
  echo "12345" > "$TMP_FOLDER/PID"
  rm -f "$TMP_FOLDER/TARGET_WINDOW_ID"
  kitty-window-highlight-reset() { echo "called" > "$BATS_TMP_DIR/reset-called.txt"; }
  bats_mock kitty-window-highlight-reset

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/reset-called.txt" ]]
}

