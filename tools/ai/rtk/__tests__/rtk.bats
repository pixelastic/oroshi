bats_load_library 'helper'

setup() {
  bats_tmp_dir
  FILTERS_TOML="$BATS_TEST_DIRNAME/../config/filters.toml"
  mkdir -p "$BATS_TMP_DIR/rtk"
  cp "$FILTERS_TOML" "$BATS_TMP_DIR/rtk/filters.toml"
  # force rtk to use the local filters.toml instead of the global one
  export XDG_CONFIG_HOME="$BATS_TMP_DIR"

  # aberlaas/vitest hardcoded excluding **/tmp/**
  # BATS_TMP_DIR is under /tmp so vitest cannot discover JS fixtures placed
  # there. We create our own tmp dir inside __tests__/ (which vitest does
  # include) and clean it up in teardown().
  local slug="$(bats_slugify "$BATS_TEST_DESCRIPTION")"
  FIXTURE_DIR="$BATS_TEST_DIRNAME/.bats-tmp/$slug"
  mkdir -p "$FIXTURE_DIR"
}

teardown() {
  bats_cleanup
  rm -rf "$FIXTURE_DIR"
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

@test "rtk yarn run test on all-passing file outputs exactly 'All tests passed.'" {
  printf 'import { test, expect } from "vitest"\ntest("passes", () => { expect(1).toBe(1) })\n' >"$FIXTURE_DIR/all-pass.js"

  run rtk yarn run test "$FIXTURE_DIR/all-pass.js"
  [ "$status" -eq 0 ]
  [ "$output" = "All tests passed." ]
}

@test "rtk yarn run test on failing file suppresses passing lines and shows failure details" {
  printf 'import { test, expect } from "vitest"\ntest("passes", () => { expect(1).toBe(1) })\ntest("fails", () => { expect(1).toBe(2) })\n' >"$FIXTURE_DIR/failure.js"

  run rtk yarn run test "$FIXTURE_DIR/failure.js"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AssertionError"* ]]
  [[ "$output" != *"✓"* ]]
}
