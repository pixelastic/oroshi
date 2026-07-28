bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-single-bracket.zsh" "batsLintRule_noSingleBracket" "test.bats" "$@"
}

@test "flags basic single bracket assertion" {
  run_this_rule '[ "$status" -eq 0 ]'
  expect_rule_violation noSingleBracket 1
}

@test "flags indented single bracket" {
  run_this_rule '  [ -f "$file" ]'
  expect_rule_violation noSingleBracket 1
}

@test "reports correct line numbers for multiple violations" {
  run_this_rule '[ "$status" -eq 0 ]' 'echo ok' '  [ -f "$file" ]'
  expect_rule_violation noSingleBracket 1
  expect_rule_violation noSingleBracket 3
}

@test "double bracket is not flagged" {
  run_this_rule '[[ "$status" -eq 0 ]]'
  expect_clean
}

@test "single bracket in comment is not flagged" {
  run_this_rule '# [ "$x" -eq 0 ]'
  expect_clean
}

@test "single bracket in test title is not flagged" {
  run_this_rule '@test "checks [ bracket" {'
  expect_clean
}
