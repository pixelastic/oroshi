#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-split-local.zsh" "zshLintRule_noSplitLocal" "test.zsh" "$@"
}

@test "flags bare local followed by assignment" {
  run_this_rule 'local foo' 'foo="$(cmd)"'
  expect_rule_violation noSplitLocal 1
}

@test "flags bare local -a followed by array assignment" {
  run_this_rule 'local -a arr' 'arr=(a b c)'
  expect_rule_violation noSplitLocal 1
}

@test "flags bare local followed by += assignment" {
  run_this_rule 'local foo' 'foo+="extra"'
  expect_rule_violation noSplitLocal 1
}

@test "clean — local with assignment on same line" {
  run_this_rule 'local foo="$(cmd)"'
  expect_clean
}

@test "clean — local with unrelated next line" {
  run_this_rule 'local foo' '[[ "$bar" == "" ]] && return 0'
  expect_clean
}

@test "clean — comment between local and unrelated line" {
  run_this_rule 'local foo' '# comment' 'bar="something"'
  expect_clean
}

@test "clean — two separate locals" {
  run_this_rule 'local foo' 'local bar="$(cmd)"'
  expect_clean
}

@test "line number points to local declaration" {
  run_this_rule '' 'local foo' 'foo="$(cmd)"'
  expect_rule_violation noSplitLocal 2
}
