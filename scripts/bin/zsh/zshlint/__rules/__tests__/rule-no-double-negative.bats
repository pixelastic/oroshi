#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-double-negative.zsh"
RULE_FN="zshlintRule_noDoubleNegative"

@test "flags [[ ! var != \"\" ]]" {
  run_rule '[[ ! "$branchSlug" != "" ]] && return 1'
  expect_violation noDoubleNegative 1
}

@test "flags [[ ! var != other ]]" {
  run_rule '[[ ! "$foo" != "bar" ]]'
  expect_violation noDoubleNegative 1
}

@test "clean — [[ var == \"\" ]]" {
  run_rule '[[ "$branchSlug" == "" ]] && return 1'
  expect_clean
}

@test "clean — [[ var != \"\" ]]" {
  run_rule '[[ "$foo" != "" ]] && return 1'
  expect_clean
}

@test "clean — [[ ! var == \"\" ]]" {
  run_rule '[[ ! "$foo" == "" ]] && return 1'
  expect_clean
}

@test "clean — comment line" {
  run_rule '# [[ ! "$foo" != "" ]]'
  expect_clean
}

@test "line number is correct" {
  run_rule '' '[[ ! "$branchSlug" != "" ]] && return 1'
  expect_violation noDoubleNegative 2
}
