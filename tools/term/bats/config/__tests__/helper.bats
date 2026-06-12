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

# @test "function chain: baz resolves from the current OROSHI_ROOT" {
#   bats_run_zsh "bats-fixture-function-foo"
#   [ "$status" -eq 0 ]
#   [[ "$output" == "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/term/bats/bats-fixture-function-baz" ]]
# }
