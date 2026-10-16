bats_load_library 'helper'

setup() {
  bats_tmp_dir

  kitty-window-id() { echo "42"; }
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-window-id kitty-remote
}

@test "passes --reset with current window id when no arg given" {
  bats_run_zsh "kitty-window-highlight-reset"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "set-colors --match id:42 --reset" ]]
}

@test "passes --reset with explicit window id when arg given" {
  bats_run_zsh "kitty-window-highlight-reset 99"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "set-colors --match id:99 --reset" ]]
}
