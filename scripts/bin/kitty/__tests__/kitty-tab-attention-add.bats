bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "add: creates attention file and parent dir if absent" {
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/kitty/attention" ]]
}

@test "add: appends tab ID to attention file" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "10" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  grep -q "^42$" "$BATS_TMP_DIR/kitty/attention"
}

@test "add: idempotent — same tab ID not duplicated" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "42" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ "$(grep -c "^42$" "$BATS_TMP_DIR/kitty/attention")" -eq 1 ]]
}

@test "add: triggers kitty-redraw" {
  kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/redraw-called" ]]
}
