bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "reads clipboard and sends bracket-paste to the correct window id" {
  clipboard-read() { echo "hello world"; }
  kitty-remote() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
  bats_mock clipboard-read kitty-remote

  bats_run_zsh "kitty-window-paste 42"

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-args")" == "send-text --bracketed-paste enable --match id:42 hello world" ]]
}

@test "returns early without calling kitty-remote when clipboard is empty" {
  clipboard-read() { echo ""; }
  kitty-remote() { echo "called" >"$BATS_TMP_DIR/kitty-called"; }
  bats_mock clipboard-read kitty-remote

  bats_run_zsh "kitty-window-paste 42"

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/kitty-called" ]]
}
