bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../__lib/zsh-lint-custom.zsh'"
}

# PASS cases {{{
@test "clean file produces no errors" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# nothing here\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'"code":"noOrBlock"'* ]]
}

@test "comment line with || { is skipped" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '  # cmd || { echo "nope"; }\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"noOrBlock"'* ]]
}

@test "|| return without brace does not trigger" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'cmd || return 1\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" != *'"code":"noOrBlock"'* ]]
}
# }}}

# FAIL cases {{{
@test "cmd || { triggers noOrBlock error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'cmd || {\n  echo "fail"\n}\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"noOrBlock"'* ]]
}

@test "]] || { triggers noOrBlock error" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '[[ -z "$x" ]] || {\n  echo "fail"\n}\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-custom $file"
  [[ "$output" == *'"code":"noOrBlock"'* ]]
}
# }}}
