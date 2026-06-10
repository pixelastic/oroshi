bats_load_library 'helper'

setup() {
  CURRENT="$(realpath "${BATS_TEST_DIRNAME}/../colors-refresh")"
}

@test "does not call kitty-refresh (SIGUSR1 reload)" {
  run grep -c "kitty-refresh" "$CURRENT"
  [ "$output" = "0" ]
}

@test "calls kitty @ set-colors to reload colors from OROSHI_ROOT" {
  run grep -c "kitty @ set-colors" "$CURRENT"
  [ "$output" != "0" ]
}

@test "set-colors points to OROSHI_ROOT kitty colors.conf" {
  run grep "kitty @ set-colors" "$CURRENT"
  [[ "$output" == *'$OROSHI_ROOT/tools/term/kitty/config/colors.conf'* ]]
}
