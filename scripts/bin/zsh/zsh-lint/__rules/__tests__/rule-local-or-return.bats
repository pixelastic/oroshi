#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-local-or-return.zsh"
RULE_FN="zshLintRule_localOrReturn"
RULE_FIXTURE="test.zsh"

@test "flags local with || chained" {
  local -a input=( 'local foo="$(cmd)" || return 1' )
  run_rule "${input[@]}"
  expect_rule_violation localOrReturn 1
}

@test "flags local with || chained — no value" {
  local -a input=( 'local foo || return 1' )
  run_rule "${input[@]}"
  expect_rule_violation localOrReturn 1
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
