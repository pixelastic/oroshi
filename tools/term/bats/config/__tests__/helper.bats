bats_load_library 'helper'

# Fixture call chain: foo → bar → baz
# Each exists as both a script (bats-fixture-script-*) and an autoload function
# (bats-fixture-function-*). Tests use this chain to verify worktree-aware
# resolution, deep-mocking at any link, and OROSHI_ROOT override propagation.

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

# --- Root Override ---

@test "root override: baz sees overridden OROSHI_ROOT" {
  bats-fixture-script-baz() { echo "$OROSHI_ROOT"; }
  bats_mock bats-fixture-script-baz

  bats_mock_oroshi_root "/tmp/test-root"

  bats_run_zsh "bats-fixture-script-foo"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/test-root" ]
}

@test "root override: composable with worktree-aware" {
  bats-fixture-script-baz() { echo "$OROSHI_ROOT"; }
  bats_mock bats-fixture-script-baz

  bats_mock_oroshi_root "/tmp/test-root"

  bats_run_zsh "bats-fixture-script-foo"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/test-root" ]

  bats_run_zsh "which bats-fixture-script-bar"
  [ "$status" -eq 0 ]
  [[ "$output" == "$OROSHI_ROOT/scripts/bin/term/bats/bats-fixture-script-bar" ]]
}

# --- bats_cleanup guard ---

@test "bats_cleanup returns 0 when BATS_TMP_DIR is unset" {
  unset BATS_TMP_DIR
  run bats_cleanup
  [ "$status" -eq 0 ]
}

@test "bats_cleanup returns 0 when BATS_TMP_DIR is empty string" {
  BATS_TMP_DIR=""
  run bats_cleanup
  [ "$status" -eq 0 ]
}

@test "bats_cleanup removes directory when BATS_TMP_DIR is set" {
  [ -d "$BATS_TMP_DIR" ]
  run bats_cleanup
  [ "$status" -eq 0 ]
  [ ! -d "$BATS_TMP_DIR" ]
}
