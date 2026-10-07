bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-s.zsh"
}

@test "widget: runs git-commit-create-all-auto" {
  run-command() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-s-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "git-commit-create-all-auto" ]]
}

@test "binding: ^S is bound to the Ctrl+S widget" {
  bats_run_zsh "${sourcePrefix}; bindkey '^S'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-s-widget"* ]]
}
