bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-top-level-var.zsh" "batsLintRule_noTopLevelVar" "test.bats" "$@"
}

@test "detects uppercase variable at top level" {
  run_this_rule 'BATS_LINT="${BATS_TEST_DIRNAME}/../bats-lint"'
  expect_rule_violation noTopLevelVar 1
}

@test "detects SCRIPT variable at top level" {
  run_this_rule 'SCRIPT="${BATS_TEST_DIRNAME}/../my-script.zsh"'
  expect_rule_violation noTopLevelVar 1
}

@test "detects CURRENT at top level (wrong location)" {
  run_this_rule 'CURRENT="${BATS_TEST_DIRNAME}/../my-script.zsh"'
  expect_rule_violation noTopLevelVar 1
}

@test "no violation for indented variable in setup" {
  run_this_rule 'setup() {' '  CURRENT="${BATS_TEST_DIRNAME}/../my-script.zsh"' '}'
  expect_clean
}

@test "no violation for bats_load_library" {
  run_this_rule "bats_load_library 'helper'"
  expect_clean
}

@test "correct line number" {
  run_this_rule 'bats_load_library helper' 'bats_load_library rules-helper' 'BATS_LINT="${BATS_TEST_DIRNAME}/../bats-lint"'
  expect_rule_violation noTopLevelVar 3
}

@test "no violation for lowercase var (local in test)" {
  run_this_rule 'file="$BATS_TMP_DIR/test.bats"'
  expect_clean
}
