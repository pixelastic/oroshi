bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-or-guard.zsh" "zshLintRule_noOrGuard" "test.zsh" "$@"
}

@test "flags [[ cond ]] || return" {
  run_this_rule '[[ "$foo" == "" ]] || return 1'
  expect_rule_violation noOrGuard 1
}

@test "flags [[ cond ]] || exit" {
  run_this_rule '[[ "$foo" == "" ]] || exit 0'
  expect_rule_violation noOrGuard 1
}

@test "flags [[ cond ]] || continue" {
  run_this_rule '[[ "$foo" == "" ]] || continue'
  expect_rule_violation noOrGuard 1
}

@test "flags with no space before ||" {
  run_this_rule '[[ "$foo" == "" ]]|| return 1'
  expect_rule_violation noOrGuard 1
}

@test "clean — [[ cond ]] && return" {
  run_this_rule '[[ "$foo" == "" ]] && return 1'
  expect_clean
}

@test "clean — command || return (no [[)" {
  run_this_rule 'some-command || return 1'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ "$foo" == "" ]] || return'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ "$foo" == "" ]] || return 1'
  expect_rule_violation noOrGuard 2
}
