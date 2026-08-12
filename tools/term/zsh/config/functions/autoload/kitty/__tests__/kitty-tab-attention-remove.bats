bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "remove: removes a tabId:stop entry" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  printf "10:stop\n42:stop\n" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  run ! grep -q "^42:" "$BATS_TMP_DIR/kitty/attention"
}

@test "remove: removes a tabId:notification entry" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  printf "10:stop\n42:notification\n" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  run ! grep -q "^42:" "$BATS_TMP_DIR/kitty/attention"
}

@test "remove: does not affect other tab IDs" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  printf "10:stop\n42:notification\n99:stop\n" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  grep -q "^10:stop$" "$BATS_TMP_DIR/kitty/attention"
  grep -q "^99:stop$" "$BATS_TMP_DIR/kitty/attention"
}

@test "remove: no-op when tab ID not in file" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "10:stop" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty/attention")" == "10:stop" ]]
}

@test "remove: no-op when attention file does not exist" {
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
}
