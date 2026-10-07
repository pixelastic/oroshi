bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source $OROSHI_ROOT/tools/term/zsh/config/keybindings/ctrl-shift-s.zsh"
}

@test "widget: runs the commit-then-ralph function through run-command" {
  run-command() { echo "$@" >"$BATS_TMP_DIR/calls"; }
  bats_mock run-command

  bats_run_zsh "${sourcePrefix}; oroshi-ctrl-shift-s-widget"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "oroshi-commit-then-ralph" ]]
}

@test "commit-then-ralph: runs ralph after a successful commit" {
  git-commit-create-all-auto() { echo commit >>"$BATS_TMP_DIR/calls"; }
  ralph() { echo ralph >>"$BATS_TMP_DIR/calls"; }
  bats_mock git-commit-create-all-auto ralph

  bats_run_zsh "${sourcePrefix}; oroshi-commit-then-ralph"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" = $'commit\nralph' ]]
}

@test "commit-then-ralph: skips ralph when the commit fails" {
  git-commit-create-all-auto() {
    echo commit >>"$BATS_TMP_DIR/calls"
    return 1
  }
  ralph() { echo ralph >>"$BATS_TMP_DIR/calls"; }
  bats_mock git-commit-create-all-auto ralph

  bats_run_zsh "${sourcePrefix}; oroshi-commit-then-ralph"
  [[ "$(cat "$BATS_TMP_DIR/calls")" = "commit" ]]
}

@test "binding: Ⓢ is bound to the Ctrl+Shift+S widget" {
  bats_run_zsh "${sourcePrefix}; bindkey 'Ⓢ'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"oroshi-ctrl-shift-s-widget"* ]]
}
