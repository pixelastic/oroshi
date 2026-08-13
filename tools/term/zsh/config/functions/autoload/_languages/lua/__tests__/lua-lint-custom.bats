bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SEP=$'\u25ae'
}

@test "exits 0 with no output for a clean file" {
  local file="$BATS_TMP_DIR/clean.lua"
  printf '%s\n' '-- clean' >"$file"
  bats_run_zsh "lua-lint-custom '$file'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "outputs violation line for vim.deepcopy( call" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' 'local x = vim.deepcopy(t)' >"$file"
  bats_run_zsh "lua-lint-custom '$file'"
  [[ "$output" == "${file}${SEP}noVimDeepcopy${SEP}"* ]]
}

@test "violation line contains correct line number" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' '-- comment' 'local x = vim.deepcopy(t)' >"$file"
  bats_run_zsh "lua-lint-custom '$file'"
  [[ "$output" == *"${SEP}2${SEP}"* ]]
}

@test "exits 1 when violation found" {
  local file="$BATS_TMP_DIR/bad.lua"
  printf '%s\n' 'local x = vim.deepcopy(t)' >"$file"
  bats_run_zsh "lua-lint-custom '$file'"
  [[ "$status" -eq 1 ]]
}
