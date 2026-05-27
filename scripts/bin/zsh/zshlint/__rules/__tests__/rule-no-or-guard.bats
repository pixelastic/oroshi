#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-or-guard.zsh"
RULE_FN="zshlintRule_noOrGuard"

@test "flags [[ cond ]] || return" {
  run_rule '[[ "$foo" == "" ]] || return 1'
  expect_violation noOrGuard 1
}

@test "flags [[ cond ]] || exit" {
  run_rule '[[ "$foo" == "" ]] || exit 0'
  expect_violation noOrGuard 1
}

@test "flags [[ cond ]] || continue" {
  run_rule '[[ "$foo" == "" ]] || continue'
  expect_violation noOrGuard 1
}

@test "flags with no space before ||" {
  run_rule '[[ "$foo" == "" ]]|| return 1'
  expect_violation noOrGuard 1
}

@test "clean — [[ cond ]] && return" {
  run_rule '[[ "$foo" == "" ]] && return 1'
  expect_clean
}

@test "clean — command || return (no [[)" {
  run_rule 'some-command || return 1'
  expect_clean
}

@test "clean — comment line" {
  run_rule '# [[ "$foo" == "" ]] || return'
  expect_clean
}

@test "line number is correct" {
  run_rule '' '[[ "$foo" == "" ]] || return 1'
  expect_violation noOrGuard 2
}
