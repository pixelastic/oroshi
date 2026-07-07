bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env KITTY_WINDOW_ID "42"
}

@test "single: sends selected path with trailing space" {
  kitty-overlay-window-id() { echo "7"; }
  ctrl-p() { echo "/foo/bar.txt"; }
  kitty-window-send-text() { echo "$*" >"$BATS_TMP_DIR/send-text-args"; }
  bats_mock kitty-overlay-window-id ctrl-p kitty-window-send-text

  bats_run_zsh "kitty-ctrl-p"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/send-text-args")" == "7 /foo/bar.txt " ]]
}

@test "multi: sends all paths shell-quoted and space-joined with trailing space" {
  kitty-overlay-window-id() { echo "7"; }
  ctrl-p() { printf "/a/b.txt\n/c/d.txt"; }
  kitty-window-send-text() { echo "$*" >"$BATS_TMP_DIR/send-text-args"; }
  bats_mock kitty-overlay-window-id ctrl-p kitty-window-send-text

  bats_run_zsh "kitty-ctrl-p"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/send-text-args")" == "7 /a/b.txt /c/d.txt " ]]
}

@test "spaces: shell-quotes path with spaces as a single token" {
  kitty-overlay-window-id() { echo "7"; }
  ctrl-p() { echo "/foo/my file.txt"; }
  kitty-window-send-text() { echo "$*" >"$BATS_TMP_DIR/send-text-args"; }
  bats_mock kitty-overlay-window-id ctrl-p kitty-window-send-text

  bats_run_zsh "kitty-ctrl-p"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/send-text-args")" == "7 '/foo/my file.txt' " ]]
}

@test "no-selection: exits 0 without sending text when ctrl-p exits non-zero" {
  kitty-overlay-window-id() { echo "7"; }
  ctrl-p() { return 1; }
  kitty-window-send-text() { echo "$*" >"$BATS_TMP_DIR/send-text-args"; }
  bats_mock kitty-overlay-window-id ctrl-p kitty-window-send-text

  bats_run_zsh "kitty-ctrl-p"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/send-text-args" ]]
}

@test "empty: exits 0 without sending text when ctrl-p output is empty" {
  kitty-overlay-window-id() { echo "7"; }
  ctrl-p() { true; }
  kitty-window-send-text() { echo "$*" >"$BATS_TMP_DIR/send-text-args"; }
  bats_mock kitty-overlay-window-id ctrl-p kitty-window-send-text

  bats_run_zsh "kitty-ctrl-p"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/send-text-args" ]]
}
