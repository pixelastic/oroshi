#!/usr/bin/env bats

bats_load_library 'helper'

LUA_LINT_SELENE="${BATS_TEST_DIRNAME}/../lua-lint-selene"
SEP=$'\u25ae'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "exits 0 with no output for clean file" {
  local file="$BATS_TMP_DIR/clean.lua"
  printf '%s\n' '-- clean' >"$file"
  run zsh "$LUA_LINT_SELENE" "$file"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "outputs violation line in file▮code▮level▮line▮message format" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf 'undefined_func()\n' >"$file"
  run zsh "$LUA_LINT_SELENE" "$file"
  [[ "$output" == "${file}${SEP}undefined_variable${SEP}error${SEP}1${SEP}"* ]]
}

@test "exits 1 when violation found" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf 'undefined_func()\n' >"$file"
  run zsh "$LUA_LINT_SELENE" "$file"
  [ "$status" -eq 1 ]
}
