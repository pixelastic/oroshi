bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-inline-function.zsh" "batsLintRule_noInlineFunction" "test.bats" "$@"
}

@test "detects two-instruction inline function" {
  run_this_rule 'foo() { cmd1; cmd2; }'
  expect_rule_violation noInlineFunction 1
}

@test "detects two-instruction inline function without trailing semicolon" {
  run_this_rule 'foo() { cmd1; cmd2 }'
  expect_rule_violation noInlineFunction 1
}

@test "no violation for single-instruction inline function" {
  run_this_rule 'foo() { cmd1; }'
  expect_clean
}

@test "no violation for single-instruction inline function without trailing semicolon" {
  run_this_rule 'foo() { cmd1 }'
  expect_clean
}

@test "no violation for empty inline function" {
  run_this_rule 'foo() { }'
  expect_clean
}

@test "no violation for multi-line function" {
  run_this_rule 'foo() {' '  cmd1' '  cmd2' '}'
  expect_clean
}

@test "correct line number" {
  run_this_rule 'setup() {' '  load helper' '}' 'foo() { cmd1; cmd2; }'
  expect_rule_violation noInlineFunction 4
}

@test "three occurrences each on correct line" {
  run_this_rule 'a() { x; y; }' 'b() { ok; }' 'c() { x; y; z; }'
  expect_rule_violation noInlineFunction 1
  expect_rule_violation noInlineFunction 3
}

# Line-length threshold: > 90 chars triggers violation even with one instruction
@test "detects single-instruction inline function over 90 characters" {
  run_this_rule 'run_this_rule() { run_rule "${BATS_TEST_DIRNAME}/../rule-no-inline-function.zsh" "batsLintRule_noInlineFunction" "test.bats" "$@"; }'
  expect_rule_violation noInlineFunction 1
}

@test "no violation for short single-instruction inline function" {
  run_this_rule 'setup() { bats_tmp_dir; }'
  expect_clean
}

