bats_load_library 'helper'

setup() {
  bats_tmp_dir
  NOTIFICATION_HOOK="$BATS_TEST_DIRNAME/../notification"
  kitty-notify() { printf '%s' "$*" > "$BATS_TMP_DIR/kitty-notify-args"; }
  bats_mock kitty-notify
}

# Run the notification hook with a given stdin JSON payload
run_notification() {
  local stdinJson="$1"
  bats_run_zsh "$NOTIFICATION_HOOK" <<< "$stdinJson"
}

@test "notifies on a permission_prompt" {
  run_notification '{"notification_type":"permission_prompt"}'

  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-notification.mp3" ]]
}

@test "notifies on an elicitation_dialog" {
  run_notification '{"notification_type":"elicitation_dialog"}'

  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-notification.mp3" ]]
}

@test "notifies on an elicitation_url_dialog" {
  run_notification '{"notification_type":"elicitation_url_dialog"}'

  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound claude-notification.mp3" ]]
}

@test "exits with code 2 on a blocking prompt" {
  run_notification '{"notification_type":"permission_prompt"}'

  [[ "$status" -eq 2 ]]
}

@test "does not notify on an idle_prompt" {
  run_notification '{"notification_type":"idle_prompt"}'

  [[ ! -f "$BATS_TMP_DIR/kitty-notify-args" ]]
}

@test "exits 0 on an idle_prompt" {
  run_notification '{"notification_type":"idle_prompt"}'

  [[ "$status" -eq 0 ]]
}

@test "does not notify when notification_type is absent" {
  run_notification '{"message":"anything"}'

  [[ ! -f "$BATS_TMP_DIR/kitty-notify-args" ]]
}
