bats_load_library 'helper'

setup() {
  bats_tmp_dir

  kitty-window-id() { echo "42"; }
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-window-id kitty-remote
}

@test "passes correct color and current window id to kitty-remote set-colors" {
  bats_run_zsh "kitty-window-highlight '#d69e2e'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "set-colors --match id:42 background=#d69e2e" ]]
}

@test "passes correct color and explicit window id when --window is used" {
  bats_run_zsh "kitty-window-highlight --window 99 '#ff0000'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "set-colors --match id:99 background=#ff0000" ]]
}
