bats_load_library 'helper'

setup() {
  bats_tmp_dir
  NOTIFICATION_HOOK="$BATS_TEST_DIRNAME/../notification"
  kitty-notify() { printf '%s' "$*" > "$BATS_TMP_DIR/kitty-notify-args"; }
  bats_mock kitty-notify
}

@test "calls kitty-notify --sound claude-notification.mp3" {
  bats_run_zsh "$NOTIFICATION_HOOK"

  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-notification.mp3" ]]
}

@test "exits with code 2" {
  bats_run_zsh "$NOTIFICATION_HOOK"

  [[ "$status" -eq 2 ]]
}
