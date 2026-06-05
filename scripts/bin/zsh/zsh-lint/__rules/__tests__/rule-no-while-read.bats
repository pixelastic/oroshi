#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-while-read.zsh" "zshLintRule_noWhileRead" "test.zsh" "$@"
}

@test "flags 'while IFS= read -r line'" {
  local -a input=( 'while IFS= read -r line; do' )
  run_this_rule "${input[@]}"
  expect_rule_violation noWhileRead 1
}

@test "flags 'while read line'" {
  local -a input=( 'while read line; do' )
  run_this_rule "${input[@]}"
  expect_rule_violation noWhileRead 1
}

@test "clean — 'while true' without read on same line" {
  local -a input=( 'while true; do' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — readlink does not match" {
  local -a input=( 'local target="$(readlink -f "$path")"' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# while IFS= read -r line; do' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — while loop with no read" {
  local -a input=( 'while [[ -n "$line" ]]; do' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — readline does not match" {
  local -a input=( 'while readline "$prompt" line; do' )
  run_this_rule "${input[@]}"
  expect_clean
}
