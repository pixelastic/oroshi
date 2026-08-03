bats_load_library 'helper'

@test "returns a numeric PID for current shell" {
  bats_run_zsh "process-parent $$"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "defaults to current process when called without arguments" {
  bats_run_zsh "process-parent"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "returned parent PID itself exists" {
  bats_run_zsh "process-parent --reply $$ && process-exists \$REPLY"
  [[ "$status" -eq 0 ]]
}

@test "--reply produces no stdout" {
  bats_run_zsh "process-parent --reply $$"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "--reply sets REPLY to parent PID" {
  bats_run_zsh "process-parent --reply $$ && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "returns 1 for a bogus PID" {
  bats_run_zsh "process-parent 9999999"
  [[ "$status" -eq 1 ]]
}

@test "produces no output for a bogus PID" {
  bats_run_zsh "process-parent 9999999"
  [[ "$output" = "" ]]
}
