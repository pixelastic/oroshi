bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-l.zsh"
}

@test "widget: runs ls" {
  run-command() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-l-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "ls" ]]
}

@test "binding: ^L is bound to the Ctrl+L widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^L'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-l-widget"* ]]
}
