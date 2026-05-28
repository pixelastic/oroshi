#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-dash-z.zsh"
RULE_FN="zshlintRule_noDashZ"
RULE_FIXTURE="test.zsh"

@test "flags [[ -z var ]]" {
  run_rule '[[ -z "$foo" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "flags [[ ! -z var ]]" {
  run_rule '[[ ! -z "$foo" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "flags -z after &&" {
  run_rule '[[ "$a" == "" && -z "$b" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "clean — [[ var == \"\" ]]" {
  run_rule '[[ "$foo" == "" ]] && return'
  expect_clean
}

@test "clean — [[ var != \"\" ]]" {
  run_rule '[[ "$foo" != "" ]] && return'
  expect_clean
}

@test "clean — -n is not flagged" {
  run_rule '[[ -n "$foo" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_rule '# [[ -z "$foo" ]]'
  expect_clean
}

@test "clean — -z outside [[ ]]" {
  run_rule 'echo -z "$foo"'
  expect_clean
}

@test "line number is correct" {
  run_rule '' '[[ -z "$foo" ]]'
  expect_rule_violation noDashZ 2
}
