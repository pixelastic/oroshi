#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-no-dash-n.zsh"
RULE_FN="zshlintRule_noDashN"

@test "flags [[ -n var ]]" {
  run_rule '[[ -n "$foo" ]] && return'
  expect_violation noDashN 1
}

@test "flags [[ ! -n var ]]" {
  run_rule '[[ ! -n "$foo" ]] && return'
  expect_violation noDashN 1
}

@test "flags -n after &&" {
  run_rule '[[ "$a" != "" && -n "$b" ]] && return'
  expect_violation noDashN 1
}

@test "clean — [[ var != \"\" ]]" {
  run_rule '[[ "$foo" != "" ]] && return'
  expect_clean
}

@test "clean — [[ var == \"\" ]]" {
  run_rule '[[ "$foo" == "" ]] && return'
  expect_clean
}

@test "clean — -z is not flagged" {
  run_rule '[[ -z "$foo" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_rule '# [[ -n "$foo" ]]'
  expect_clean
}

@test "clean — -n outside [[ ]]" {
  run_rule 'echo -n "$foo"'
  expect_clean
}

@test "line number is correct" {
  run_rule '' '[[ -n "$foo" ]]'
  expect_violation noDashN 2
}
