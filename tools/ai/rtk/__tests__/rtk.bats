bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FILTERS_TOML="$BATS_TEST_DIRNAME/../config/filters.toml"
  mkdir -p "$BATS_TMP_DIR/rtk"
  cp "$FILTERS_TOML" "$BATS_TMP_DIR/rtk/filters.toml"
  # force rtk to use the local filters.toml instead of the global one
  export XDG_CONFIG_HOME="$BATS_TMP_DIR"
}

teardown() {
  bats_cleanup
}

@test "rtk bats on all-passing file outputs exactly 'All tests passed.'" {
  printf '@test "passes" { true; }\n' >"$BATS_TMP_DIR/all-pass.bats"

  run rtk bats "$BATS_TMP_DIR/all-pass.bats"
  [ "$status" -eq 0 ]
  [ "$output" = "All tests passed." ]
}

@test "rtk bats on failing file outputs not-ok lines and suppresses ok lines" {
  printf '@test "passes" { true; }\n@test "fails" { false; }\n' >"$BATS_TMP_DIR/failure.bats"

  run rtk bats "$BATS_TMP_DIR/failure.bats"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not ok"* ]]
  [[ "$output" != *"ok 1"* ]]
  [[ "$output" != *"1..2"* ]]
}
