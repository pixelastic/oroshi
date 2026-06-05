#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() { run_rule "${BATS_TEST_DIRNAME}/../rule-no-run-zsh.zsh" "batsLintRule_noRunZsh" "test.bats" "$@"; }

@test "detects run zsh" {
  run_this_rule 'run zsh -c "echo hello"'
  expect_rule_violation noRunZsh 1
}

@test "no violation when no run zsh" {
  run_this_rule '@test "something" { bats_run_function echo; }'
  expect_clean
}

@test "inline disable skips violation" {
  run_this_rule 'run zsh -c "echo" # bats-lint-disable noRunZsh'
  expect_clean
}

@test "three occurrences each on correct line" {
  run_this_rule 'run zsh -c "a"' 'bats_run_function fn' 'run zsh -c "b"' 'echo ok' 'run zsh -c "c"'
  expect_rule_violation noRunZsh 1
  expect_rule_violation noRunZsh 3
  expect_rule_violation noRunZsh 5
}

@test "correct line number" {
  run_this_rule '@test "first" {' 'run zsh -c "echo"' '}'
  expect_rule_violation noRunZsh 2
}

@test "run zsh in comment is not flagged" {
  run_this_rule '# run zsh -c "echo"'
  expect_clean
}

@test "run zsh in test title is not flagged" {
  run_this_rule '@test "calls run zsh directly" {'
  expect_clean
}

@test "run zsh in string literal is not flagged" {
  run_this_rule "printf 'run zsh -c \"echo\"\n' >\"\$file\""
  expect_clean
}
