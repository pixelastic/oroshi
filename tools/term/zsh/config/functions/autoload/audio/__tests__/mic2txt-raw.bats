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
  mic2txt-autosubmit-mode-is-enabled() { return 0; }
  mic2txt-autosubmit-mode-is-clipboard() { return 1; }
  mic2txt-postprocess-mode() { echo none; }
  mic2txt-postprocess-midjourney() { cat; }
  mic2txt-cancel() { :; }
  mic2txt-paste() { :; }
  focus-insert() { :; }
  better-ydotool() { :; }
  sleep() { :; }
  kitty-os-window-is-focused() { return 1; }
  kitty-window-id() { echo "0"; }
  kitty-window-highlight() { :; }
  kitty-window-highlight-reset() { :; }
  bats_mock rec process-kill audio-play-oroshi mic2txt-autosubmit-mode-is-enabled mic2txt-autosubmit-mode-is-clipboard mic2txt-postprocess-mode mic2txt-postprocess-midjourney mic2txt-cancel mic2txt-paste focus-insert better-ydotool sleep kitty-os-window-is-focused kitty-window-id kitty-window-highlight kitty-window-highlight-reset
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

@test "does not highlight when kitty is focused at start in clipboard state" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 0; }
  kitty-window-id() { echo "42"; }
  mic2txt-autosubmit-mode-is-clipboard() { return 0; }
  kitty-window-highlight() { echo "called" > "$BATS_TMP_DIR/highlight-called"; }
  bats_mock kitty-os-window-is-focused kitty-window-id mic2txt-autosubmit-mode-is-clipboard kitty-window-highlight

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/highlight-called" ]]
}

@test "does not create TARGET_WINDOW_ID when kitty is focused at start in clipboard state" {
  rm -f "$TMP_FOLDER/PID"
  kitty-os-window-is-focused() { return 0; }
  kitty-window-id() { echo "42"; }
  mic2txt-autosubmit-mode-is-clipboard() { return 0; }
  bats_mock kitty-os-window-is-focused kitty-window-id mic2txt-autosubmit-mode-is-clipboard

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$TMP_FOLDER/TARGET_WINDOW_ID" ]]
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

# --- Slack mode removed ---

@test "transcription completes without calling txt2slack" {
  echo "12345" > "$TMP_FOLDER/PID"
  txt2slack() { echo "called" > "$BATS_TMP_DIR/txt2slack-called.txt"; }
  bats_mock txt2slack

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/txt2slack-called.txt" ]]
}

# --- Translate mode removed ---

@test "transcription completes without calling translate" {
  echo "12345" > "$TMP_FOLDER/PID"
  mic2txt-language() { echo "en"; }
  translate() { echo "called" > "$BATS_TMP_DIR/translate-called.txt"; }
  bats_mock mic2txt-language translate

  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/translate-called.txt" ]]
}


# --- Postprocess none ---

# Run a full stop cycle (recording started 5s ago) with a fake transcription
stop_with_transcription() {
  echo "12345" > "$TMP_FOLDER/PID"
  local libFolder="$BATS_TMP_DIR/oroshi/tools/term/zsh/config/functions/autoload/audio/__lib"
  mkdir -p "$libFolder"
  # colors-load-definitions reads the theming build from OROSHI_ROOT
  ln --symbolic --force "$OROSHI_ROOT/tools/term/zsh/config/theming" "$BATS_TMP_DIR/oroshi/tools/term/zsh/config/theming"
  echo "#!/bin/sh" > "$libFolder/fake-wav2txt"
  echo "echo 'un chat roux'" >> "$libFolder/fake-wav2txt"
  chmod +x "$libFolder/fake-wav2txt"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
  bats_run_zsh "zmodload zsh/datetime; echo \$(( EPOCHREALTIME - 5 )) > $TMP_FOLDER/START_TIME && mic2txt-raw --wav2txt fake-wav2txt"
}

# Mock the postprocess as midjourney, logging sounds and calls in order
mock_midjourney_postprocess() {
  mic2txt-postprocess-mode() { echo midjourney; }
  audio-play-oroshi() { echo "play $1" >> "$BATS_TMP_DIR/events"; }
  mic2txt-postprocess-midjourney() {
    echo "postprocess $(cat)" >> "$BATS_TMP_DIR/events"
    echo "a red cat"
  }
  mic2txt-paste() { echo "paste" >> "$BATS_TMP_DIR/events"; }
  bats_mock mic2txt-postprocess-mode audio-play-oroshi mic2txt-postprocess-midjourney mic2txt-paste
}

@test "none: does not call any postprocess helper" {
  mic2txt-postprocess-midjourney() {
    echo "called" > "$BATS_TMP_DIR/postprocess-called.txt"
    cat
  }
  bats_mock mic2txt-postprocess-midjourney

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/postprocess-called.txt" ]]
}

@test "none: plays mic2txt-before.mp3 and mic2txt.mp3 as before" {
  audio-play-oroshi() { echo "play $1" >> "$BATS_TMP_DIR/events"; }
  bats_mock audio-play-oroshi

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/events")" == $'play mic2txt-before.mp3\nplay mic2txt.mp3' ]]
}

# --- Postprocess midjourney ---

@test "midjourney: plays mic2txt-midjourney-start.mp3 when the recording starts" {
  rm -f "$TMP_FOLDER/PID"
  mock_midjourney_postprocess

  bats_run_zsh "mic2txt-raw --wav2txt echo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/events")" == "play mic2txt-midjourney-start.mp3" ]]
}

@test "midjourney: plays mic2txt-midjourney-sent.mp3 instead of mic2txt-before.mp3" {
  mock_midjourney_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  grep --quiet "play mic2txt-midjourney-sent.mp3" "$BATS_TMP_DIR/events"
  [[ "$(cat "$BATS_TMP_DIR/events")" != *"play mic2txt-before.mp3"* ]]
}

@test "midjourney: plays mic2txt-midjourney-transcribed.mp3 before the postprocess" {
  mock_midjourney_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  local events="$(cat "$BATS_TMP_DIR/events")"
  [[ "$events" == *"play mic2txt-midjourney-transcribed.mp3"$'\n'"postprocess"* ]]
}

@test "midjourney: passes the autocorrected transcription to mic2txt-postprocess-midjourney" {
  mock_midjourney_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  grep --quiet "postprocess un chat roux" "$BATS_TMP_DIR/events"
}

@test "midjourney: writes the postprocess result to transcription.txt" {
  mock_midjourney_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$TMP_FOLDER/transcription.txt")" == "a red cat" ]]
}

@test "midjourney: plays mic2txt-midjourney-end.mp3 then calls mic2txt-paste" {
  mock_midjourney_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  local events="$(cat "$BATS_TMP_DIR/events")"
  [[ "$events" == *"play mic2txt-midjourney-end.mp3"$'\n'"paste" ]]
  [[ "$(cat "$BATS_TMP_DIR/events")" != *"play mic2txt.mp3"* ]]
}

# --- Postprocess failure ---

# Same as mock_midjourney_postprocess, but the postprocess fails
mock_failing_postprocess() {
  mock_midjourney_postprocess
  mic2txt-postprocess-midjourney() {
    cat > /dev/null
    return 1
  }
  kitty-window-highlight-reset() { echo "$@" >> "$BATS_TMP_DIR/reset-calls"; }
  bats_mock mic2txt-postprocess-midjourney kitty-window-highlight-reset
}

@test "postprocess failure: plays mic2txt-cancel.mp3" {
  mock_failing_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  grep --quiet "play mic2txt-cancel.mp3" "$BATS_TMP_DIR/events"
  [[ "$(cat "$BATS_TMP_DIR/events")" != *"play mic2txt-midjourney-end.mp3"* ]]
}

@test "postprocess failure: does not call mic2txt-paste" {
  mock_failing_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/events")" != *paste* ]]
}

@test "postprocess failure: treats an empty result as a failure" {
  mock_failing_postprocess
  mic2txt-postprocess-midjourney() { cat > /dev/null; }
  bats_mock mic2txt-postprocess-midjourney

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  grep --quiet "play mic2txt-cancel.mp3" "$BATS_TMP_DIR/events"
  [[ "$(cat "$BATS_TMP_DIR/events")" != *paste* ]]
}

@test "postprocess failure: keeps the raw transcription in transcription.txt" {
  mock_failing_postprocess

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$TMP_FOLDER/transcription.txt")" == "un chat roux" ]]
}

@test "postprocess failure: resets the kitty highlight and removes TARGET_WINDOW_ID" {
  mock_failing_postprocess
  echo "42" > "$TMP_FOLDER/TARGET_WINDOW_ID"

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/reset-calls")" == "42" ]]
  [[ ! -f "$TMP_FOLDER/TARGET_WINDOW_ID" ]]
}

@test "midjourney: pastes the result when the postprocess exits non-zero with output" {
  mock_midjourney_postprocess
  mic2txt-postprocess-midjourney() {
    cat > /dev/null
    echo "a red cat"
    return 1
  }
  bats_mock mic2txt-postprocess-midjourney

  stop_with_transcription
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/events")" == *paste ]]
  [[ "$(cat "$TMP_FOLDER/transcription.txt")" == "a red cat" ]]
}
