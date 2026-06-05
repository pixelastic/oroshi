#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() { run_rule "${BATS_TEST_DIRNAME}/../rule-no-arith-flag-test.zsh" "zshLintRule_noArithFlagTest" "test.zsh" "$@"; }

@test "flags (( isZsh ))" {
  run_this_rule 'if (( isZsh )); then'
  expect_rule_violation noArithFlagTest 1
}

@test "flags (( isWithIcon ))" {
  run_this_rule '(( isWithIcon )) && icon="x"'
  expect_rule_violation noArithFlagTest 1
}

@test "line number is correct" {
  run_this_rule 'local x=1' '(( isRemote )) && return 0'
  expect_rule_violation noArithFlagTest 2
}

@test "clean — (( isZsh == 1 )) comparison" {
  run_this_rule 'if (( isZsh == 1 )); then'
  expect_clean
}

@test "clean — (( ++lineno )) arithmetic" {
  run_this_rule '(( ++lineno ))'
  expect_clean
}

@test "clean — [[ \$isZsh == \"1\" ]] preferred form" {
  run_this_rule '[[ $isZsh == "1" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# (( isZsh ))'
  expect_clean
}

@test "clean — local string assignment containing pattern" {
  run_this_rule "local msg='Prefer [[ \$isXxx == \"1\" ]] over (( isXxx ))'"
  expect_clean
}
