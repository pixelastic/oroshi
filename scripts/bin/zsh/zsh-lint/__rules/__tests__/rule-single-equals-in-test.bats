bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-single-equals-in-test.zsh" "zshLintRule_singleEqualsInTest" "test.zsh" "$@"
}

@test "flags '[[ \"\$foo\" = \"bar\" ]]'" {
  local -a input=( '[[ "$foo" = "bar" ]]' )
  run_this_rule "${input[@]}"
  expect_rule_violation singleEqualsInTest 1
}

@test "flags '[[ \$x = \$y ]]' without quotes" {
  local -a input=( '[[ $x = $y ]]' )
  run_this_rule "${input[@]}"
  expect_rule_violation singleEqualsInTest 1
}

@test "clean — '!=' is not flagged" {
  local -a input=( '[[ "$foo" != "bar" ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — '=~' is not flagged" {
  local -a input=( '[[ $x =~ pattern ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — '<=' is not flagged" {
  local -a input=( '[[ "$x" <= "$y" ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — '>=' is not flagged" {
  local -a input=( '[[ "$x" >= "$y" ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — '==' is not flagged" {
  local -a input=( '[[ "$foo" == "bar" ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# [[ "$foo" = "bar" ]]' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — variable assignment after ']]' on same line" {
  local -a input=( '[[ "$foo" == "bar" ]]; x=1' )
  run_this_rule "${input[@]}"
  expect_clean
}
