bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-dash-z.zsh" "zshLintRule_noDashZ" "test.zsh" "$@"
}

@test "flags [[ -z var ]]" {
  run_this_rule '[[ -z "$foo" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "flags [[ ! -z var ]]" {
  run_this_rule '[[ ! -z "$foo" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "flags -z after &&" {
  run_this_rule '[[ "$a" == "" && -z "$b" ]] && return'
  expect_rule_violation noDashZ 1
}

@test "clean — [[ var == \"\" ]]" {
  run_this_rule '[[ "$foo" == "" ]] && return'
  expect_clean
}

@test "clean — [[ var != \"\" ]]" {
  run_this_rule '[[ "$foo" != "" ]] && return'
  expect_clean
}

@test "clean — -n is not flagged" {
  run_this_rule '[[ -n "$foo" ]] && return'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ -z "$foo" ]]'
  expect_clean
}

@test "clean — -z outside [[ ]]" {
  run_this_rule 'echo -z "$foo"'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ -z "$foo" ]]'
  expect_rule_violation noDashZ 2
}
