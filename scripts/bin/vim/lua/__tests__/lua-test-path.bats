#!/usr/bin/env bats

bats_load_library 'helper'

LUA_TEST_PATH="${BATS_TEST_DIRNAME}/../lua-test-path"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "returns path when given an existing _spec.lua file" {
  local file="$BATS_TMP_DIR/foo_spec.lua"
  touch "$file"
  run "$LUA_TEST_PATH" "$file"
  [ "$status" -eq 0 ]
  [ "$output" = "$file" ]
}

@test "exits 1 when given a _spec.lua path that does not exist" {
  run "$LUA_TEST_PATH" "/nonexistent/foo_spec.lua"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "resolves source file to its spec when spec exists" {
  local dir="$BATS_TMP_DIR"
  mkdir -p "$dir/__tests__"
  touch "$dir/lodash.lua"
  touch "$dir/__tests__/lodash_spec.lua"
  run "$LUA_TEST_PATH" "$dir/lodash.lua"
  [ "$status" -eq 0 ]
  [ "$output" = "$dir/__tests__/lodash_spec.lua" ]
}

@test "exits 1 silently when no spec exists for a source file" {
  local dir="$BATS_TMP_DIR"
  touch "$dir/lodash.lua"
  run "$LUA_TEST_PATH" "$dir/lodash.lua"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "exits 1 with no arguments" {
  run "$LUA_TEST_PATH"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}
