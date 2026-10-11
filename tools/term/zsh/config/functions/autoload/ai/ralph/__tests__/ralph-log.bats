bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR"
  bats_mock_env "KITTY_WINDOW_ID" "42"
}

@test "appends the message with the window id to the ralph log" {
  bats_run_zsh "ralph-log 'ralph-end: hello'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$BATS_TMP_DIR/ralph-debug.log")" == *" win=42 ralph-end: hello" ]]
}

@test "appends one line per call" {
  bats_run_zsh "ralph-log first; ralph-log second"
  [[ "$(wc -l <"$BATS_TMP_DIR/ralph-debug.log")" -eq 2 ]]
}

@test "does nothing without a state folder" {
  bats_mock_env "OROSHI_FOLDER_STATE" ""
  bats_run_zsh "ralph-log hello"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/ralph-debug.log" ]]
}
