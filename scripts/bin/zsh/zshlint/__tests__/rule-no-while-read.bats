#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-no-while-read.zsh"
RULE_FN="zshlintRule_noWhileRead"

@test "flags 'while IFS= read -r line'" {
  local -a input=( 'while IFS= read -r line; do' )
  run_rule "${input[@]}"
  expect_violation 90004 1
}

@test "flags 'while read line'" {
  local -a input=( 'while read line; do' )
  run_rule "${input[@]}"
  expect_violation 90004 1
}

@test "clean — 'while true' without read on same line" {
  local -a input=( 'while true; do' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — readlink does not match" {
  local -a input=( 'local target="$(readlink -f "$path")"' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# while IFS= read -r line; do' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — while loop with no read" {
  local -a input=( 'while [[ -n "$line" ]]; do' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — readline does not match" {
  local -a input=( 'while readline "$prompt" line; do' )
  run_rule "${input[@]}"
  expect_clean
}
