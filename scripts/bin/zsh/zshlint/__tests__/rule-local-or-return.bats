#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-local-or-return.zsh"
RULE_FN="zshlintRule_localOrReturn"

@test "flags local with || chained" {
  local -a input=( 'local foo="$(cmd)" || return 1' )
  run_rule "${input[@]}"
  expect_violation localOrReturn 1
}

@test "flags local with || chained — no value" {
  local -a input=( 'local foo || return 1' )
  run_rule "${input[@]}"
  expect_violation localOrReturn 1
}

@test "clean — || inside quoted value" {
  local -a input=( 'local msg="yes || no"' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# local foo="$(cmd)" || return 1' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — no || at all" {
  local -a input=( 'local foo="bar"' )
  run_rule "${input[@]}"
  expect_clean
}
