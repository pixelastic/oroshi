bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="${BATS_TEST_DIRNAME}/../lua-lint-custom"
  SEP=$'\u25ae'
}

teardown() {
  bats_cleanup
}

@test "exits 0 with no output for a clean file" {
  local file="$BATS_TMP_DIR/clean.lua"
  printf '%s\n' '-- clean' >"$file"
  run "$CURRENT" "$file"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "outputs violation line for vim.deepcopy( call" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' 'local x = vim.deepcopy(t)' >"$file"
  run "$CURRENT" "$file"
  [[ "$output" == "${file}${SEP}noVimDeepcopy${SEP}"* ]]
}

@test "violation line contains correct line number" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' '-- comment' 'local x = vim.deepcopy(t)' >"$file"
  run "$CURRENT" "$file"
  [[ "$output" == *"${SEP}2${SEP}"* ]]
}

@test "exits 1 when violation found" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' 'local x = vim.deepcopy(t)' >"$file"
  run "$CURRENT" "$file"
  [ "$status" -eq 1 ]
}
