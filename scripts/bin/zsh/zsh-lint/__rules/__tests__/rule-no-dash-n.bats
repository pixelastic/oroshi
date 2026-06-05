#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() { run_rule "${BATS_TEST_DIRNAME}/../rule-no-dash-n.zsh" "zshLintRule_noDashN" "test.zsh" "$@"; }

@test "flags [[ -n var ]]" {
  run_this_rule '[[ -n "$foo" ]] && return'
  expect_rule_violation noDashN 1
}

@test "flags [[ ! -n var ]]" {
  run_this_rule '[[ ! -n "$foo" ]] && return'
  expect_rule_violation noDashN 1
}

@test "flags -n after &&" {
  run_this_rule '[[ "$a" != "" && -n "$b" ]] && return'
  expect_rule_violation noDashN 1
}

@test "clean — [[ var != \"\" ]]" {
  run_this_rule '[[ "$foo" != "" ]] && return'
  expect_clean
}

@test "clean — [[ var == \"\" ]]" {
  run_this_rule '[[ "$foo" == "" ]] && return'
  expect_clean
}

@test "clean — -z is not flagged" {
  run_this_rule '[[ -z "$foo" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ -n "$foo" ]]'
  expect_clean
}

@test "clean — -n outside [[ ]]" {
  run_this_rule 'echo -n "$foo"'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ -n "$foo" ]]'
  expect_rule_violation noDashN 2
}
