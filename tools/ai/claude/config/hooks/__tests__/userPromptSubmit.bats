bats_load_library 'helper'

setup() {
  bats_tmp_dir
  HOOK="$BATS_TEST_DIRNAME/../userPromptSubmit"
}

run_hook() {
  bats_run_zsh "$HOOK" <<< ""
}

@test "removes attention for current tab when KITTY_WINDOW_ID is set" {
  export KITTY_WINDOW_ID="42"
  kitty-window-tab-id() { echo "7"; }
  kitty-tab-attention-remove() { echo "$1" > "$BATS_TMP_DIR/removed"; }
  bats_mock kitty-window-tab-id kitty-tab-attention-remove

  run_hook

  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/removed")" = "7" ]]
}

@test "silent exit 0 when KITTY_WINDOW_ID is absent" {
  unset KITTY_WINDOW_ID
  kitty-tab-attention-remove() { touch "$BATS_TMP_DIR/removed"; }
  bats_mock kitty-tab-attention-remove

  run_hook

  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/removed" ]]
}
