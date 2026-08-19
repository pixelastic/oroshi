bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Default mocks: tab not focused, tabId=42
  kitty-window-tab-id() { echo "42"; }
  kitty-tab-focused() { return 1; }
  kitty-tab-notification-add() { echo "$1" > "$BATS_TMP_DIR/notification-add-arg"; }
  audio-play-oroshi() { echo "$1" > "$BATS_TMP_DIR/sound-played"; }
  bats_mock kitty-window-tab-id kitty-tab-focused kitty-tab-notification-add audio-play-oroshi
}

# When tab is not focused

@test "adds a Notification Marker when tab is not focused" {
  bats_run_zsh "kitty-notify"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/notification-add-arg")" == "42" ]]
}

@test "plays the sound when --sound is provided and tab is not focused" {
  bats_run_zsh "kitty-notify --sound claude-stop.mp3"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/sound-played")" == "claude-stop.mp3" ]]
}

@test "plays the default sound when --sound is omitted" {
  bats_run_zsh "kitty-notify"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/sound-played")" == "notification.mp3" ]]
}

@test "does not play sound when --sound no" {
  bats_run_zsh "kitty-notify --sound no"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/sound-played" ]]
}

# When tab is focused

@test "does not add a Notification Marker when tab is focused" {
  kitty-tab-focused() { return 0; }
  bats_mock kitty-tab-focused

  bats_run_zsh "kitty-notify"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/notification-add-arg" ]]
}

@test "still plays the sound when tab is focused and --sound is provided" {
  kitty-tab-focused() { return 0; }
  bats_mock kitty-tab-focused

  bats_run_zsh "kitty-notify --sound claude-stop.mp3"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/sound-played")" == "claude-stop.mp3" ]]
}

# Error resilience

@test "returns 0 and still plays sound when kitty-window-tab-id fails" {
  kitty-window-tab-id() { return 1; }
  bats_mock kitty-window-tab-id

  bats_run_zsh "kitty-notify --sound claude-stop.mp3"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/sound-played")" == "claude-stop.mp3" ]]
}

@test "returns 0 even when audio-play-oroshi fails" {
  audio-play-oroshi() { return 1; }
  bats_mock audio-play-oroshi

  bats_run_zsh "kitty-notify --sound claude-stop.mp3"

  [[ "$status" -eq 0 ]]
}
