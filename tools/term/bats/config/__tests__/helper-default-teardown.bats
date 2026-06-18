bats_load_library 'helper'

# Verifies that the helper's default teardown() cleans up BATS_TMP_DIR
# automatically when a test file does not define its own teardown().
#
# We can't test this in helper.bats because that file defines teardown(),
# which overrides the default. This file intentionally omits teardown().
#
# Strategy: the first test saves its BATS_TMP_DIR path to a coordination
# file outside the sandbox (since BATS_TMP_DIR itself gets deleted by
# teardown). The second test reads that path and asserts the directory
# no longer exists — proving the default teardown ran between tests.

setup() {
  COORDINATION="/tmp/oroshi/bats/default-teardown-coordination"
  bats_tmp_dir
}

# No teardown() — relies on the default from helper

@test "default teardown removes temp directory" {
  local dir="$BATS_TMP_DIR"
  [ -d "$dir" ]

  # Save path outside sandbox so it survives teardown
  echo "$dir" > "$COORDINATION"
}

@test "previous test temp dir was cleaned up" {
  local prev_dir
  prev_dir="$(cat "$COORDINATION")"
  [ ! -d "$prev_dir" ]
  rm -f "$COORDINATION"
}
