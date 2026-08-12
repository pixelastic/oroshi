bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "calls kitty focus-tab with tab ID" {
  kitty() { echo "$@" > "$BATS_TMP_DIR/kitty-args.txt"; }
  bats_mock kitty

  bats_run_zsh "kitty-tab-switch 42"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args.txt")" == "@ focus-tab --match id:42" ]]
}

@test "propagates non-zero exit from kitty" {
  kitty() { return 1; }
  bats_mock kitty

  bats_run_zsh "kitty-tab-switch 999"

  [[ "$status" -ne 0 ]]
}
