#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-single-equals-in-test.zsh"
RULE_FN="zshLintRule_singleEqualsInTest"
RULE_FIXTURE="test.zsh"

@test "flags '[[ \"\$foo\" = \"bar\" ]]'" {
  local -a input=( '[[ "$foo" = "bar" ]]' )
  run_rule "${input[@]}"
  expect_rule_violation singleEqualsInTest 1
}

@test "flags '[[ \$x = \$y ]]' without quotes" {
  local -a input=( '[[ $x = $y ]]' )
  run_rule "${input[@]}"
  expect_rule_violation singleEqualsInTest 1
}

@test "clean — '!=' is not flagged" {
  local -a input=( '[[ "$foo" != "bar" ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — '=~' is not flagged" {
  local -a input=( '[[ $x =~ pattern ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — '<=' is not flagged" {
  local -a input=( '[[ "$x" <= "$y" ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — '>=' is not flagged" {
  local -a input=( '[[ "$x" >= "$y" ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — '==' is not flagged" {
  local -a input=( '[[ "$foo" == "bar" ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# [[ "$foo" = "bar" ]]' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — variable assignment after ']]' on same line" {
  local -a input=( '[[ "$foo" == "bar" ]]; x=1' )
  run_rule "${input[@]}"
  expect_clean
}
