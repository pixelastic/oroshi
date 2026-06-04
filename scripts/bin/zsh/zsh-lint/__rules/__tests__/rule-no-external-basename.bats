#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-external-basename.zsh"
RULE_FN="zshLintRule_noExternalBasename"
RULE_FIXTURE="test.zsh"

@test "flags \$(basename ...)" {
  local -a input=( 'local name="$(basename "$path")"' )
  run_rule "${input[@]}"
  expect_rule_violation noExternalBasename 1
}

@test "flags \$(dirname ...)" {
  local -a input=( 'local dir="$(dirname "$path")"' )
  run_rule "${input[@]}"
  expect_rule_violation noExternalBasename 1
}

@test "flags \$(realpath ...)" {
  local -a input=( 'local real="$(realpath "$path")"' )
  run_rule "${input[@]}"
  expect_rule_violation noExternalBasename 1
}

@test "clean — comment line with basename" {
  local -a input=( '# use basename or :t modifier' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — bare word basename in string (no subshell)" {
  local -a input=( 'echo "basename is the old way"' )
  run_rule "${input[@]}"
  expect_clean
}

@test "clean — zsh :t modifier" {
  local -a input=( 'local name="${path:t}"' )
  run_rule "${input[@]}"
  expect_clean
}
