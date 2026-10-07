bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-w.zsh"
}

@test "widget: runs git-file-watch" {
  run-command() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-w-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "git-file-watch" ]]
}

@test "binding: ^W is bound to the Ctrl+W widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^W'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-w-widget"* ]]
}
