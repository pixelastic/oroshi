bats_load_library 'helper'

@test "returns the working directory for current shell PID" {
  bats_run_zsh "process-cwd $$"
  [[ "$status" -eq 0 ]]
  [[ -d "$output" ]]
}

@test "defaults to current process when called without arguments" {
  bats_run_zsh "process-cwd"
  [[ "$status" -eq 0 ]]
  [[ -d "$output" ]]
}

@test "returns 1 for a bogus PID" {
  bats_run_zsh "process-cwd 9999999"
  [[ "$status" -eq 1 ]]
}

@test "produces no output for a bogus PID" {
  bats_run_zsh "process-cwd 9999999"
  [[ "$output" = "" ]]
}
