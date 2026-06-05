#!/usr/bin/env bats
# shellcheck disable=SC2016  # $foo in single-quoted printf is intentional

bats_load_library 'helper'

SCRIPT="${BATS_TEST_DIRNAME}/../zsh-lint-shellcheck.zsh"

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  printf 'zsh-lint-shellcheck "$@"\n' >"$CURRENT"
  printf "source '%s'\n" "$SCRIPT" >"$BATS_TMP_DIR/mock.zsh"
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "excludes SC2086 — unquoted variable produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo $foo\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == '[]' ]]
}

@test "excludes SC2155 — local with command substitution produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local foo="$(date)"\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == '[]' ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
