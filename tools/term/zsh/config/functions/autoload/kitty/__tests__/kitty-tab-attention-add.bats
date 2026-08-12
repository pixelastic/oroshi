bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "add: no --type flag writes tabId:stop" {
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  grep -q "^42:stop$" "$BATS_TMP_DIR/kitty/attention"
}

@test "add: --type notification writes tabId:notification" {
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42 --type notification"

  [[ "$status" -eq 0 ]]
  grep -q "^42:notification$" "$BATS_TMP_DIR/kitty/attention"
}

@test "add: same tab ID not duplicated" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "42:stop" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ "$(grep -c "^42:" "$BATS_TMP_DIR/kitty/attention")" -eq 1 ]]
}

@test "add: same tab ID with different type replaces entry" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "42:stop" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { :; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42 --type notification"

  [[ "$status" -eq 0 ]]
  [[ "$(grep -c "^42:" "$BATS_TMP_DIR/kitty/attention")" -eq 1 ]]
  grep -q "^42:notification$" "$BATS_TMP_DIR/kitty/attention"
}

@test "add: triggers kitty-redraw on new entry" {
  kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/redraw-called" ]]
}

@test "add: does not trigger kitty-redraw when entry already exists" {
  mkdir -p "$BATS_TMP_DIR/kitty"
  echo "42:stop" >"$BATS_TMP_DIR/kitty/attention"
  kitty-redraw() { touch "$BATS_TMP_DIR/redraw-called"; }
  bats_mock kitty-redraw

  bats_run_zsh "kitty-tab-attention-add 42"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/redraw-called" ]]
}
