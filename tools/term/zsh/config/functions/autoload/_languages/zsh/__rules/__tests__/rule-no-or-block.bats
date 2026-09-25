bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-or-block.zsh" "zshLintRule_noOrBlock" "test.zsh" "$@"
}

@test "flags cmd || {" {
  run_this_rule 'cmd || {' '  echo "fail"' '}'
  expect_rule_violation noOrBlock 1
}

@test "flags ]] || {" {
  run_this_rule '[[ -z "$x" ]] || {' '  echo "fail"' '}'
  expect_rule_violation noOrBlock 1
}

@test "clean — no || block" {
  run_this_rule '# nothing here'
  expect_clean
}

@test "clean — || return without brace" {
  run_this_rule 'cmd || return 1'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '  # cmd || { echo "nope"; }'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' 'cmd || {' '  echo "fail"' '}'
  expect_rule_violation noOrBlock 2
}
