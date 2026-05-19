#!/usr/bin/env bats

load '../../../__tests__/helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-no-manual-arg-parsing.zsh"
RULE_FN="zshlintRule_noManualArgParsing"

@test "flags case \"\$1\" pattern" {
  local -a input=(
    'case "$1" in'
    '  --foo) foo=1 ;;'
    'esac'
  )
  run_rule "${input[@]}"
  expect_violation 90005 1
}

@test "flags while getopts pattern" {
  local -a input=( 'while getopts "f:v" opt; do' )
  run_rule "${input[@]}"
  expect_violation 90005 1
}

@test "clean — zparseopts" {
  local -a input=(
    'zmodload zsh/zutil'
    'zparseopts -E -D f=flagFoo'
  )
  run_rule "${input[@]}"
  expect_clean
}

@test "no false positive on comment line" {
  local -a input=( '# case "$1" is the old way' )
  run_rule "${input[@]}"
  expect_clean
}

@test "no false positive on case \"\$2\"" {
  local -a input=( 'case "$2" in' )
  run_rule "${input[@]}"
  expect_clean
}
