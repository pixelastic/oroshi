bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-r.zsh"
}

@test "widget: runs ralph" {
  run-command-silent() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command-silent

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-r-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "ralph" ]]
}

@test "binding: ^R is bound to the Ctrl+R widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^R'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-r-widget"* ]]
}
