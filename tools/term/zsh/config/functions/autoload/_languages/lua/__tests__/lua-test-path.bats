bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns path when given an existing _spec.lua file" {
  local file="$BATS_TMP_DIR/foo_spec.lua"
  touch "$file"
  bats_run_zsh "lua-test-path '$file'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$file" ]]
}

@test "exits 1 when given a _spec.lua path that does not exist" {
  bats_run_zsh "lua-test-path /nonexistent/foo_spec.lua"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "resolves source file to its spec when spec exists" {
  local dir="$BATS_TMP_DIR"
  mkdir -p "$dir/__tests__"
  touch "$dir/lodash.lua"
  touch "$dir/__tests__/lodash_spec.lua"
  bats_run_zsh "lua-test-path '$dir/lodash.lua'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$dir/__tests__/lodash_spec.lua" ]]
}

@test "exits 1 silently when no spec exists for a source file" {
  local dir="$BATS_TMP_DIR"
  touch "$dir/lodash.lua"
  bats_run_zsh "lua-test-path '$dir/lodash.lua'"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "exits 1 with no arguments" {
  bats_run_zsh "lua-test-path"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}
