#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() { run_rule "${BATS_TEST_DIRNAME}/../rule-no-vim-deepcopy.zsh" "luaLintRule_noVimDeepcopy" "test.lua" "$@"; }

@test "flags vim.deepcopy( call" {
  local -a input=( 'local x = vim.deepcopy(t)' )
  run_this_rule "${input[@]}"
  expect_rule_violation noVimDeepcopy 1
}

@test "flags vim.deepcopy( on the correct line number" {
  run_this_rule '-- comment' 'local x = vim.deepcopy(t)'
  expect_rule_violation noVimDeepcopy 2
}

@test "clean — file without vim.deepcopy" {
  run_this_rule '-- clean' 'local x = vim.tbl_deep_extend("force", a, b)'
  expect_clean
}

@test "clean — comment line containing vim.deepcopy" {
  run_this_rule '-- vim.deepcopy( is deprecated'
  expect_clean
}
