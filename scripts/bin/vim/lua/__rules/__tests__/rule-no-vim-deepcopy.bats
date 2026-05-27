#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

RULE_FILE="${BATS_TEST_DIRNAME}/../rule-no-vim-deepcopy.zsh"
RULE_FN="luaLintRule_noVimDeepcopy"
RULE_FIXTURE="test.lua"

@test "flags vim.deepcopy( call" {
  local -a input=( 'local x = vim.deepcopy(t)' )
  run_rule "${input[@]}"
  expect_rule_violation noVimDeepcopy 1
}

@test "flags vim.deepcopy( on the correct line number" {
  run_rule '-- comment' 'local x = vim.deepcopy(t)'
  expect_rule_violation noVimDeepcopy 2
}

@test "clean — file without vim.deepcopy" {
  run_rule '-- clean' 'local x = vim.tbl_deep_extend("force", a, b)'
  expect_clean
}

@test "clean — comment line containing vim.deepcopy" {
  run_rule '-- vim.deepcopy( is deprecated'
  expect_clean
}
