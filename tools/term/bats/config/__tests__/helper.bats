bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

# --- Worktree-aware ---

@test "script chain: baz resolves from the current OROSHI_ROOT" {
  bats_run_zsh "bats-fixture-script-foo"
  [ "$status" -eq 0 ]
  [[ "$output" == "$OROSHI_ROOT/scripts/bin/term/bats/bats-fixture-script-baz" ]]
}

@test "function chain: baz resolves from the current OROSHI_ROOT" {
  bats_run_zsh "bats-fixture-function-foo"
  [ "$status" -eq 0 ]
  [[ "$output" == "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/term/bats/bats-fixture-function-baz" ]]
}

# --- Deep-mocking ---

@test "mock baz - same process function chain" {
  bats-fixture-function-baz() { echo "mocked"; }
  bats_mock bats-fixture-function-baz

  bats_run_zsh "bats-fixture-function-foo"
  [ "$status" -eq 0 ]
  [ "$output" = "mocked" ]
}

@test "mock baz - subshell" {
  bats-fixture-function-baz() { echo "mocked"; }
  bats_mock bats-fixture-function-baz

  bats_run_zsh 'echo $(bats-fixture-function-foo)'
  [ "$status" -eq 0 ]
  [ "$output" = "mocked" ]
}

@test "mock baz - external PATH script chain" {
  bats-fixture-script-baz() { echo "mocked"; }
  bats_mock bats-fixture-script-baz

  bats_run_zsh "bats-fixture-script-foo"
  [ "$status" -eq 0 ]
  [ "$output" = "mocked" ]
}

@test "mock wins over worktree binary when called directly" {
  bats-fixture-script-baz() { echo "mocked"; }
  bats_mock bats-fixture-script-baz

  bats_run_zsh "bats-fixture-script-baz"
  [ "$status" -eq 0 ]
  [ "$output" = "mocked" ]
}
