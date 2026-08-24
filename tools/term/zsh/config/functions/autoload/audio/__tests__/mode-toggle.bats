bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
}

@test "cycles from first to second value" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "aaa" > "$BATS_TMP_DIR/modes/test-mode"

  bats_run_zsh "mode-toggle test-mode aaa bbb ccc"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "bbb" ]]
}

@test "cycles from second to third value" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "bbb" > "$BATS_TMP_DIR/modes/test-mode"

  bats_run_zsh "mode-toggle test-mode aaa bbb ccc"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "ccc" ]]
}

@test "wraps from last to first value" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "ccc" > "$BATS_TMP_DIR/modes/test-mode"

  bats_run_zsh "mode-toggle test-mode aaa bbb ccc"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "aaa" ]]
}

@test "writes second value when file does not exist (default is first)" {
  bats_run_zsh "mode-toggle test-mode aaa bbb ccc"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "bbb" ]]
}

@test "creates modes/ directory if missing" {
  bats_run_zsh "mode-toggle test-mode aaa bbb"
  [[ "$status" -eq 0 ]]
  [[ -d "$BATS_TMP_DIR/modes" ]]
}

@test "works with two values (boolean toggle)" {
  mkdir -p "$BATS_TMP_DIR/modes"
  echo "disabled" > "$BATS_TMP_DIR/modes/test-mode"

  bats_run_zsh "mode-toggle test-mode disabled enabled"
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "enabled" ]]

  echo "enabled" > "$BATS_TMP_DIR/modes/test-mode"
  bats_run_zsh "mode-toggle test-mode disabled enabled"
  [[ "$(cat "$BATS_TMP_DIR/modes/test-mode")" == "disabled" ]]
}
