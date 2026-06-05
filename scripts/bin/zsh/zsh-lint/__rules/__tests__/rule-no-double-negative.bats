#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-double-negative.zsh" "zshLintRule_noDoubleNegative" "test.zsh" "$@"
}

@test "flags [[ ! var != \"\" ]]" {
  run_this_rule '[[ ! "$branchSlug" != "" ]] && return 1'
  expect_rule_violation noDoubleNegative 1
}

@test "flags [[ ! var != other ]]" {
  run_this_rule '[[ ! "$foo" != "bar" ]]'
  expect_rule_violation noDoubleNegative 1
}

@test "clean — [[ var == \"\" ]]" {
  run_this_rule '[[ "$branchSlug" == "" ]] && return 1'
  expect_clean
}

@test "clean — [[ var != \"\" ]]" {
  run_this_rule '[[ "$foo" != "" ]] && return 1'
  expect_clean
}

@test "clean — [[ ! var == \"\" ]]" {
  run_this_rule '[[ ! "$foo" == "" ]] && return 1'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ ! "$foo" != "" ]]'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ ! "$branchSlug" != "" ]] && return 1'
  expect_rule_violation noDoubleNegative 2
}
