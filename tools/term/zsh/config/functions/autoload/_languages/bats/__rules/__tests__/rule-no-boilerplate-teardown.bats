bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-boilerplate-teardown.zsh" "batsLintRule_noBoilerplateTeardown" "test.bats" "$@"
}

# --- violations ---

@test "detects one-liner teardown with bats_cleanup" {
  run_this_rule 'teardown() { bats_cleanup; }'
  expect_rule_violation noBoilerplateTeardown 1
}

@test "detects multiline teardown with bats_cleanup" {
  run_this_rule 'teardown() {' '  bats_cleanup' '}'
  expect_rule_violation noBoilerplateTeardown 1
}

@test "reports correct line number" {
  run_this_rule '@test "something" {' '  echo ok' '}' '' 'teardown() { bats_cleanup; }'
  expect_rule_violation noBoilerplateTeardown 5
}

# --- no violations ---

@test "teardown with bats_cleanup plus additional statements" {
  run_this_rule 'teardown() {' '  bats_cleanup' '  rm -f /tmp/extra' '}'
  expect_clean
}

@test "file with no teardown function" {
  run_this_rule '@test "something" {' '  echo ok' '}'
  expect_clean
}

@test "file with empty teardown" {
  run_this_rule 'teardown() {' '}'
  expect_clean
}
