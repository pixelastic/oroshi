bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
}

@test "success: calls kitty set-tab-color with --match all active_bg=NONE" {
  kitty() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty

  bats_run_zsh "kitty-redraw"

  [ "$status" -eq 0 ]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "@ set-tab-color --match all active_bg=NONE" ]]
}

@test "success: silent output" {
  kitty() { :; }
  bats_mock kitty

  bats_run_zsh "kitty-redraw"

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "failure: exits non-zero if kitty is unreachable" {
  kitty() { return 1; }
  bats_mock kitty

  bats_run_zsh "kitty-redraw"

  [ "$status" -ne 0 ]
}

@test "success: creates beacon before calling kitty" {
  kitty() {
    if [[ -f "$BATS_TMP_DIR/kitty/beacons/redraw" ]]; then
      touch "$BATS_TMP_DIR/beacon-existed"
    fi
  }
  bats_mock kitty

  bats_run_zsh "kitty-redraw"

  [ "$status" -eq 0 ]
  [[ -f "$BATS_TMP_DIR/beacon-existed" ]]
}
