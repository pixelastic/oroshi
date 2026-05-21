#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-single-equals-in-test.zsh"
RULE_FN="zshlintRule_singleEqualsInTest"

@test "flags '[[ \"\$foo\" = \"bar\" ]]'" {
  local -a input=( '[[ "$foo" = "bar" ]]' )
  run_rule "${input[@]}"
  expect_violation 90006 1
}

@test "flags '[[ \$x = \$y ]]' without quotes" {
  local -a input=( '[[ $x = $y ]]' )
  run_rule "${input[@]}"
  expect_violation 90006 1
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
