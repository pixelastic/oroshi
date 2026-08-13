bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-use-echoerr.zsh" "zshLintRule_useEchoerr" "test.zsh" "$@"
}

@test "flags echo string >&2" {
  run_this_rule 'echo "hello" >&2'
  expect_rule_violation useEchoerr 1
}

@test "flags echo >&2 string (redirect in middle)" {
  run_this_rule 'echo >&2 "hello"'
  expect_rule_violation useEchoerr 1
}

@test "flags echo string 1>&2 (explicit fd)" {
  run_this_rule 'echo "hello" 1>&2'
  expect_rule_violation useEchoerr 1
}

@test "clean — comment line with echo >&2" {
  run_this_rule '# echo "hello" >&2'
  expect_clean
}

@test "clean — echo without redirect" {
  run_this_rule 'echo "hello"'
  expect_clean
}

@test "clean — non-echo command with >&2" {
  run_this_rule 'some-cmd >&2'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' 'echo "hello" >&2'
  expect_rule_violation useEchoerr 2
}
