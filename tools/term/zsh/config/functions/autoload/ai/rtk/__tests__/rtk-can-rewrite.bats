bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() { bats_cleanup; }

@test "exits 0 for a command RTK can natively rewrite" {
  bats_run_function rtk-can-rewrite "git status"
  [ "$status" -eq 0 ]
}

@test "exits 0 for a command matching a TOML filter name" {
  bats_run_function rtk-can-rewrite "bats foo.bats"
  [ "$status" -eq 0 ]
}

@test "exits 1 for an unrecognized command" {
  bats_run_function rtk-can-rewrite "echo hello"
  [ "$status" -eq 1 ]
}

@test "produces no stdout in any case" {
  bats_run_function rtk-can-rewrite "git status"
  [ -z "$output" ]

  bats_run_function rtk-can-rewrite "bats foo.bats"
  [ -z "$output" ]

  bats_run_function rtk-can-rewrite "echo hello"
  [ -z "$output" ]
}
