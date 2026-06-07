bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/ai/rtk/rtk-can-rewrite"
}

teardown() { bats_cleanup; }

@test "exits 0 for a command RTK can natively rewrite" {
  bats_run_zsh "$CURRENT" "git status"
  [ "$status" -eq 0 ]
}

@test "exits 0 for a command matching a TOML filter name" {
  bats_run_zsh "$CURRENT" "bats foo.bats"
  [ "$status" -eq 0 ]
}

@test "exits 1 for an unrecognized command" {
  bats_run_zsh "$CURRENT" "echo hello"
  [ "$status" -eq 1 ]
}

@test "produces no stdout in any case" {
  bats_run_zsh "$CURRENT" "git status"
  [ -z "$output" ]

  bats_run_zsh "$CURRENT" "bats foo.bats"
  [ -z "$output" ]

  bats_run_zsh "$CURRENT" "echo hello"
  [ -z "$output" ]
}
