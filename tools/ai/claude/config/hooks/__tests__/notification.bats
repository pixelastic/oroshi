bats_load_library 'helper'

setup() {
  bats_tmp_dir
  NOTIFICATION_HOOK="$BATS_TEST_DIRNAME/../notification"
  audio-play-oroshi() { echo "$1" > "$BATS_TMP_DIR/sound-played"; }
  bats_mock audio-play-oroshi
}

# Mock helpers for attention tests
mock_kitty_attention() {
  kitty-window-tab-id() { echo "5"; }
  bats_mock kitty-window-tab-id
  kitty-tab-focused() { return 1; }
  bats_mock kitty-tab-focused
  kitty-tab-attention-add() { echo "$@" > "$BATS_TMP_DIR/attention-args"; }
  bats_mock kitty-tab-attention-add
}

@test "attention: added with --type notification when tab not focused" {
  mock_kitty_attention

  bats_run_zsh "$NOTIFICATION_HOOK"

  [ "$status" -eq 2 ]
  [ -f "$BATS_TMP_DIR/attention-args" ]
  [ "$(cat "$BATS_TMP_DIR/attention-args")" = "5 --type notification" ]
}

@test "attention: not added when tab is focused" {
  kitty-window-tab-id() { echo "5"; }
  kitty-tab-focused() { return 0; }
  kitty-tab-attention-add() { echo "$@" > "$BATS_TMP_DIR/attention-args"; }
  bats_mock kitty-window-tab-id kitty-tab-focused kitty-tab-attention-add

  bats_run_zsh "$NOTIFICATION_HOOK"

  [ "$status" -eq 2 ]
  [ ! -f "$BATS_TMP_DIR/attention-args" ]
}

@test "plays audio notification regardless of focus state" {
  mock_kitty_attention

  bats_run_zsh "$NOTIFICATION_HOOK"

  [ "$status" -eq 2 ]
  [ "$(cat "$BATS_TMP_DIR/sound-played")" = "claude-notification.mp3" ]
}
