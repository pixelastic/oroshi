bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "sends text to window via kitty-remote send-text" {
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock kitty-remote

  bats_run_zsh "kitty-window-send-text 7 'hello world'"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "send-text --match id:7 hello world" ]]
}

@test "no args: exits non-zero and prints usage" {
  bats_run_zsh "kitty-window-send-text"

  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}
