#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-prefer-batch-mock.zsh" \
    "batsLintRule_preferBatchMock" "test.bats" "$@"
}

@test "single bats_mock in @test is clean" {
  run_this_rule \
    '@test "one mock" {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '}'
  expect_clean
}

@test "two bats_mock in same @test flags second call" {
  run_this_rule \
    '@test "two mocks" {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '  fn2() { :; }' \
    '  bats_mock fn2' \
    '}'
  expect_rule_violation preferBatchMock 5
}

@test "three bats_mock in same @test flags second and third" {
  run_this_rule \
    '@test "three mocks" {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '  fn2() { :; }' \
    '  bats_mock fn2' \
    '  fn3() { :; }' \
    '  bats_mock fn3' \
    '}'
  expect_rule_violation preferBatchMock 5
  expect_rule_violation preferBatchMock 7
}

@test "one bats_mock per @test block is clean" {
  run_this_rule \
    '@test "first" {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '}' \
    '@test "second" {' \
    '  fn2() { :; }' \
    '  bats_mock fn2' \
    '}'
  expect_clean
}

@test "bats_mock outside @test block is clean" {
  run_this_rule \
    'fn1() { :; }' \
    'bats_mock fn1'
  expect_clean
}

@test "bats_mock with multiple args is clean" {
  run_this_rule \
    '@test "grouped" {' \
    '  fn1() { :; }' \
    '  fn2() { :; }' \
    '  bats_mock fn1 fn2' \
    '}'
  expect_clean
}

@test "single bats_mock in setup() is clean" {
  run_this_rule \
    'setup() {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '}'
  expect_clean
}

@test "two bats_mock in setup() flags second call" {
  run_this_rule \
    'setup() {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '  fn2() { :; }' \
    '  bats_mock fn2' \
    '}'
  expect_rule_violation preferBatchMock 5
}

@test "does not warn for bats_mock_oroshi_root" {
  run_this_rule \
    'setup() {' \
    '  fn1() { :; }' \
    '  bats_mock fn1' \
    '  bats_mock_oroshi_root /tmp/test-root' \
    '}'
  expect_clean
}
