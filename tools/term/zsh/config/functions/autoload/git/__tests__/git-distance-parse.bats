bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/git-distance-parse"
}

teardown() {
  bats_cleanup
}

@test "parses ahead and behind from combined string" {
  bats_run_zsh "$CURRENT" "[ahead 4, behind 1]"
  [ "$status" -eq 0 ]
  [ "$output" = "4▮1" ]
}

@test "parses ahead-only string" {
  bats_run_zsh "$CURRENT" "[ahead 3]"
  [ "$status" -eq 0 ]
  [ "$output" = "3▮0" ]
}

@test "parses behind-only string" {
  bats_run_zsh "$CURRENT" "[behind 2]"
  [ "$status" -eq 0 ]
  [ "$output" = "0▮2" ]
}

@test "returns empty for empty input" {
  bats_run_zsh "$CURRENT" ""
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
