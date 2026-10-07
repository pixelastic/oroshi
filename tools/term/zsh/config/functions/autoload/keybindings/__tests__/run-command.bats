bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Fake zle: records each widget call, so tests can check what the helper asks zle to do
  zle() { echo "$*" >>"$BATS_TMP_DIR/zle-calls"; }
  bats_mock zle
}

@test "puts the command in the buffer" {
  bats_run_zsh "run-command vcaa; echo \$BUFFER"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "vcaa" ]]
}

@test "joins the arguments into the buffer" {
  bats_run_zsh "run-command git status --short; echo \$BUFFER"
  [[ "$output" = "git status --short" ]]
}

@test "stashes the typed line, then submits the command" {
  bats_run_zsh "run-command vcaa"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/zle-calls")" = $'push-input\naccept-line' ]]
}

@test "fails without a command" {
  bats_run_zsh "run-command"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/zle-calls" ]]
}
