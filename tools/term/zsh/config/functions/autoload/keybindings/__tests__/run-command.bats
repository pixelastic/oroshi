bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Fake zle: records each widget call, so tests can check what the helper asks zle to do
  zle() { echo "$*" >>"$BATS_TMP_DIR/zle-calls"; }

  # Fake command: records its arguments
  fake-command() { echo "$*" >"$BATS_TMP_DIR/command-calls"; }

  bats_mock zle fake-command
}

@test "runs the command with its arguments" {
  bats_run_zsh "run-command fake-command --flag value"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/command-calls")" = "--flag value" ]]
}

@test "redraws the prompt after the command" {
  bats_run_zsh "run-command fake-command"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/zle-calls")" = "reset-prompt" ]]
}

@test "leaves the command line untouched" {
  bats_run_zsh "BUFFER='git sta'; run-command fake-command; echo \$BUFFER"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"git sta" ]]
}

@test "does not submit a line, so history stays clean" {
  bats_run_zsh "run-command fake-command"
  [[ "$(cat "$BATS_TMP_DIR/zle-calls")" != *"accept-line"* ]]
  [[ "$(cat "$BATS_TMP_DIR/zle-calls")" != *"push-input"* ]]
}

@test "fails without a command" {
  bats_run_zsh "run-command"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/zle-calls" ]]
}

@test "redraws the prompt even when the command fails" {
  failing-command() { return 1; }
  bats_mock failing-command

  bats_run_zsh "run-command failing-command"
  [[ "$(cat "$BATS_TMP_DIR/zle-calls")" = "reset-prompt" ]]
}
