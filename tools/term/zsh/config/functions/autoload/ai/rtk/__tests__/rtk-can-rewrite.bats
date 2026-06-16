bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() { bats_cleanup; }

@test "exits 0 for a command RTK can natively rewrite" {
  bats_run_zsh "rtk-can-rewrite 'git status'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "exits 0 for bats invocation" {
  bats_run_zsh "rtk-can-rewrite 'bats foo.bats'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "exits 0 for yarn run test" {
  bats_run_zsh "rtk-can-rewrite 'yarn run test'"
  [ "$status" -eq 0 ]
}

@test "exits 0 for yarn run test with file argument" {
  bats_run_zsh "rtk-can-rewrite 'yarn run test path/to/file.js'"
  [ "$status" -eq 0 ]
}

@test "exits 0 for yarn run test with extra flags" {
  bats_run_zsh "rtk-can-rewrite 'yarn run test path/to/file.js -- --reporter verbose'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for yarn install" {
  bats_run_zsh "rtk-can-rewrite 'yarn install'"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "exits 1 for an unrecognized command" {
  bats_run_zsh "rtk-can-rewrite 'echo hello'"
  [ "$status" -eq 1 ]
}
