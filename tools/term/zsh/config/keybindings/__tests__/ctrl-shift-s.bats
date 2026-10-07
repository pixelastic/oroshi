bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-shift-s.zsh"
}

@test "widget: runs vcaar with history" {
  run-command() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-shift-s-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "vcaar" ]]
}

@test "binding: Ⓢ is bound to the Ctrl+Shift+S widget" {
  bats_run_zsh "${sourcePrefix}; bindkey 'Ⓢ'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-shift-s-widget"* ]]
}
