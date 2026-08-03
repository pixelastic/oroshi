bats_load_library 'helper'

@test "returns 0 for current shell PID" {
  bats_run_zsh "process-exists $$"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 for a bogus PID" {
  bats_run_zsh "process-exists 9999999"
  [[ "$status" -eq 1 ]]
}

@test "defaults to current process when called without arguments" {
  bats_run_zsh "process-exists"
  [[ "$status" -eq 0 ]]
}
