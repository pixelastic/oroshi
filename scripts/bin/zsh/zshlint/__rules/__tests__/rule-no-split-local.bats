#!/usr/bin/env bats

bats_load_library 'helper'
load './helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-split-local.zsh"
RULE_FN="zshlintRule_noSplitLocal"

@test "flags bare local followed by assignment" {
  run_rule 'local foo' 'foo="$(cmd)"'
  expect_violation noSplitLocal 1
}

@test "flags bare local -a followed by array assignment" {
  run_rule 'local -a arr' 'arr=(a b c)'
  expect_violation noSplitLocal 1
}

@test "flags bare local followed by += assignment" {
  run_rule 'local foo' 'foo+="extra"'
  expect_violation noSplitLocal 1
}

@test "clean — local with assignment on same line" {
  run_rule 'local foo="$(cmd)"'
  expect_clean
}

@test "clean — local with unrelated next line" {
  run_rule 'local foo' '[[ "$bar" == "" ]] && return 0'
  expect_clean
}

@test "clean — comment between local and unrelated line" {
  run_rule 'local foo' '# comment' 'bar="something"'
  expect_clean
}

@test "clean — two separate locals" {
  run_rule 'local foo' 'local bar="$(cmd)"'
  expect_clean
}

@test "line number points to local declaration" {
  run_rule '' 'local foo' 'foo="$(cmd)"'
  expect_violation noSplitLocal 2
}
