bats_load_library 'helper'

@test "exits 0 when CLAUDECODE=1" {
  bats_mock_env CLAUDECODE "1"

  bats_run_zsh "is-claude"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits 1 when CLAUDECODE is unset" {
  bats_run_zsh "unset CLAUDECODE && is-claude"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "exits 1 when CLAUDECODE is something else" {
  bats_mock_env CLAUDECODE "0"

  bats_run_zsh "is-claude"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}
