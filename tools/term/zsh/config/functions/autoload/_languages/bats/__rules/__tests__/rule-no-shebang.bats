bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-shebang.zsh" "batsLintRule_noShebang" "test.bats" "$@"
}

@test "flags #!/usr/bin/env bats on line 1" {
  run_this_rule '#!/usr/bin/env bats'
  expect_rule_violation noShebang 1
}

@test "flags #!/bin/sh on line 1" {
  run_this_rule '#!/bin/sh'
  expect_rule_violation noShebang 1
}

@test "no violation for file with no shebang" {
  run_this_rule 'bats_load_library helper'
  expect_clean
}

@test "no violation for comment that is not a shebang" {
  run_this_rule '# not a shebang'
  expect_clean
}

@test "no violation when shebang is on line 2" {
  run_this_rule '# comment' '#!/usr/bin/env bats'
  expect_clean
}
