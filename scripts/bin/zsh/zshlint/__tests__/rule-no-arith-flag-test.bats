#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../__rules/rule-no-arith-flag-test.zsh"
RULE_FN="zshlintRule_noArithFlagTest"

@test "flags (( isZsh ))" {
  run_rule 'if (( isZsh )); then'
  expect_violation noArithFlagTest 1
}

@test "flags (( isWithIcon ))" {
  run_rule '(( isWithIcon )) && icon="x"'
  expect_violation noArithFlagTest 1
}

@test "line number is correct" {
  run_rule 'local x=1' '(( isRemote )) && return 0'
  expect_violation noArithFlagTest 2
}

@test "clean — (( isZsh == 1 )) comparison" {
  run_rule 'if (( isZsh == 1 )); then'
  expect_clean
}

@test "clean — (( ++lineno )) arithmetic" {
  run_rule '(( ++lineno ))'
  expect_clean
}

@test "clean — [[ \$isZsh == \"1\" ]] preferred form" {
  run_rule '[[ $isZsh == "1" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_rule '# (( isZsh ))'
  expect_clean
}

@test "clean — local string assignment containing pattern" {
  run_rule "local msg='Prefer [[ \$isXxx == \"1\" ]] over (( isXxx ))'"
  expect_clean
}
