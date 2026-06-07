#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-current-script-var.zsh" \
    "batsLintRule_currentScriptVar" "test.bats" "$@"
}

@test "non-CURRENT name (no braces) is flagged" {
  run_this_rule 'PRD_END_SCRIPT="$BATS_TEST_DIRNAME/../test"'
  expect_rule_violation currentScriptVar 1
}

@test "non-CURRENT name (braced form) is flagged" {
  run_this_rule 'PLAN_DIR="${BATS_TEST_DIRNAME}/../test"'
  expect_rule_violation currentScriptVar 1
}

@test "CURRENT (no braces) is not flagged" {
  run_this_rule 'CURRENT="$BATS_TEST_DIRNAME/../test"'
  expect_clean
}

@test "CURRENT (braced form) is not flagged" {
  run_this_rule 'CURRENT="${BATS_TEST_DIRNAME}/../test"'
  expect_clean
}

@test "value with trailing extension is not flagged" {
  run_this_rule 'RULE_PATH="${BATS_TEST_DIRNAME}/../test.zsh"'
  expect_clean
}

@test "value not matching basename is not flagged" {
  run_this_rule 'SCRIPT="$BATS_TEST_DIRNAME/../other"'
  expect_clean
}

@test "local prefix is not flagged" {
  run_this_rule 'local script="$BATS_TEST_DIRNAME/../test"'
  expect_clean
}

@test "string literal inside helper call is not flagged" {
  run_this_rule "  run_this_rule 'SCRIPT=\"\$BATS_TEST_DIRNAME/../test\"'"
  expect_clean
}

@test "correct line number reported" {
  run_this_rule 'CURRENT="${BATS_TEST_DIRNAME}/../test"' 'PLAN_DIR="${BATS_TEST_DIRNAME}/../test"'
  expect_rule_violation currentScriptVar 2
}

@test "indented violation inside setup is detected" {
  run_this_rule 'setup() {' '  REVIEW_SCRIPT="$BATS_TEST_DIRNAME/../test"' '}'
  expect_rule_violation currentScriptVar 2
}
