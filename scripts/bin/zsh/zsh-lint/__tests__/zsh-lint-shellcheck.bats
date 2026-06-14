bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../zsh-lint-shellcheck.zsh'"
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-shellcheck $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "excludes SC2086 — unquoted variable produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo $foo\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-shellcheck $file"
  [[ "$output" == '[]' ]]
}

@test "excludes SC2155 — local with command substitution produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local foo="$(date)"\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-shellcheck $file"
  [[ "$output" == '[]' ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "${sourcePrefix}; zsh-lint-shellcheck $file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
