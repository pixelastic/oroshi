#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

# Fixture must have no extension to simulate an autoloaded function
run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-err-return.zsh" "zshLintRule_missingErrReturn" "test" "$@"
}

@test "flags autoloaded function missing setopt err_return" {
  local -a input=( '# My function' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingErrReturn 1
}

@test "clean — setopt local_options err_return present" {
  local -a input=( '# My function' 'setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — has shebang (script, not an autoloaded function)" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — .zsh extension (sourced utility, not an autoloaded function)" {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-err-return.zsh" "zshLintRule_missingErrReturn" "test.zsh" \
    '# sourced utility' \
    'echo hello'
  expect_clean
}

@test "flags — setopt err_return in a comment does not count" {
  local -a input=( '# setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingErrReturn 1
}
