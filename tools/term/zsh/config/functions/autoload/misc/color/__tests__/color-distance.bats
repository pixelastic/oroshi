bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/misc/color/color-distance"
}

teardown() {
  bats_cleanup
}

@test "identical colors return 0" {
  bats_run_zsh "$CURRENT" "#FF0000" "#FF0000"
  [ "$output" = "0" ]
}

@test "white vs black returns 765" {
  bats_run_zsh "$CURRENT" "#FFFFFF" "#000000"
  [ "$output" = "765" ]
}

@test "small blue channel diff returns 30" {
  bats_run_zsh "$CURRENT" "#FF0000" "#FF001E"
  [ "$output" = "30" ]
}

@test "works without leading hash" {
  bats_run_zsh "$CURRENT" "FF0000" "FF001E"
  [ "$output" = "30" ]
}
