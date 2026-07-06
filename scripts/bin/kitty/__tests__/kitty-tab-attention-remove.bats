bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "remove: deletes tab ID from attention file" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  printf "10\n42\n" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  run ! grep -q "^42$" "$BATS_TMP_DIR/kitty/attention"
}

@test "remove: no-op if tab ID not in file" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "10" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty/attention")" = "10" ]]
}

@test "remove: does not affect other tab IDs" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  printf "10\n42\n99\n" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
  grep -q "^10$" "$BATS_TMP_DIR/kitty/attention"
  grep -q "^99$" "$BATS_TMP_DIR/kitty/attention"
}

@test "remove: no-op if attention file does not exist" {
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-remove 42"

  [[ "$status" -eq 0 ]]
}
