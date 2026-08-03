bats_load_library 'helper'

@test "returns the executable name for current shell PID" {
  bats_run_zsh "process-name $$"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "bash" ]]
}

@test "--reply sets REPLY without echoing" {
  bats_run_zsh "process-name --reply $$ && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "bash" ]]
}

@test "returns 1 for a bogus PID" {
  bats_run_zsh "process-name 9999999"
  [[ "$status" -eq 1 ]]
}

@test "produces no output for a bogus PID" {
  bats_run_zsh "process-name 9999999"
  [[ "$output" = "" ]]
}
