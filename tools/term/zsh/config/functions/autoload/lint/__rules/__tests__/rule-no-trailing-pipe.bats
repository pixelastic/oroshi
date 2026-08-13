bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-trailing-pipe.zsh" "zshLintRule_noTrailingPipe" "test.zsh" "$@"
}

@test "flags trailing pipe" {
  run_this_rule 'echo foo |'
  expect_rule_violation noTrailingPipe 1
}

@test "flags trailing pipe with trailing spaces" {
  run_this_rule 'echo foo |  '
  expect_rule_violation noTrailingPipe 1
}

@test "clean — || at end of line" {
  run_this_rule 'cmd ||'
  expect_clean
}

@test "clean — pipe in middle of line" {
  run_this_rule 'echo foo | grep bar'
  expect_clean
}

@test "clean — leading pipe (Google Shell Style)" {
  run_this_rule '  | grep bar'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# echo foo |'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' 'echo foo |'
  expect_rule_violation noTrailingPipe 2
}
