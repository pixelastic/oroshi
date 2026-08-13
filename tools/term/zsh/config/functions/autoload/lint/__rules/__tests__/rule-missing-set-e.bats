bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-set-e.zsh" "zshLintRule_missingSetE" "test.zsh" "$@"
}

@test "flags script missing set -e" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingSetE 1
}

@test "clean — set -e present" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -e' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — no shebang (autoloaded function, not a script)" {
  local -a input=( '# My function' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — set -ex present" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -ex' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — set -xe present" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -xe' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — set -eE present" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -eE' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "flags — set -x without e still flags" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -x' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingSetE 1
}

@test "flags — set -e in a comment does not count" {
  local -a input=( '#!/usr/bin/env zsh' '# set -e is needed' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingSetE 1
}
