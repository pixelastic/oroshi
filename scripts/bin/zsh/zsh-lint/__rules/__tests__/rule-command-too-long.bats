bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-command-too-long.zsh" "zshLintRule_commandTooLong" "test.zsh" "$@"
}

@test "flags command with pipe exceeding 100 chars" {
  local -a input=( 'somecommand argument | othercommand --flag-one value-one --flag-two value-two --flag-three value-three' )
  run_this_rule "${input[@]}"
  expect_rule_violation commandTooLong 1
}

@test "flags command with multiple --flags exceeding 100 chars" {
  local -a input=( 'mycommand --option-one value-one --option-two value-two --option-three value-three --option-four value' )
  run_this_rule "${input[@]}"
  expect_rule_violation commandTooLong 1
}

@test "flags command with long positional arguments exceeding 100 chars" {
  local -a input=( 'mycommand first-argument second-argument third-argument fourth-argument fifth-argument sixth-argument seventh' )
  run_this_rule "${input[@]}"
  expect_rule_violation commandTooLong 1
}

@test "clean — all exclusions together" {
  local -a input=(
    '# This is a very long comment that exceeds one hundred characters and should not be flagged by the rule'
    '[[ "$some_very_long_variable_name" == "$another_very_long_variable_name" && "$third" == "$fourth_var" ]]'
    'if [[ "$some_very_long_variable_name" == "$another_very_long_variable_name" && "$x_var" == "$y_var" ]]; then'
    'local very_long_variable_name="some very long value that makes this line exceed one hundred characters total"'
    'VERY_LONG_VARIABLE_NAME="some very long value that makes this line exceed one hundred characters in total xx"'
    'mycommand --opt1 val1 --opt2 val2 --opt3 val3 --opt4 val4 --opt5 val5 --opt6 val6 --opt7 val7-xxxxxx'
    'shortcmd arg'
  )
  run_this_rule "${input[@]}"
  expect_clean
}
