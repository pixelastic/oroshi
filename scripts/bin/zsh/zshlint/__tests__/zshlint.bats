#!/usr/bin/env bats
# shellcheck disable=SC2016  # $1 in single-quoted printf strings is intentional

bats_load_library 'helper'

ZSHLINT="${BATS_TEST_DIRNAME}/../zshlint"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "merges custom rule output with shellcheck JSON into single array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "returns empty array and exit 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "returns exit 1 when custom rule finds a violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "merges output from both sub-linters when both have violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zshlint-shellcheck() { printf '[{"code":2162}]\n'; }
  zshlint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zshlint-shellcheck zshlint-custom
  bats_run_script "$ZSHLINT" "$file"
  [[ "$output" == *'"code":2162'* ]]
  [[ "$output" == *'"code":90005'* ]]
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when only shellcheck finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zshlint-shellcheck() { printf '[{"code":2162}]\n'; }
  zshlint-custom()     { printf '[]\n'; }
  bats_mock zshlint-shellcheck zshlint-custom
  bats_run_script "$ZSHLINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when only custom rules find violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zshlint-shellcheck() { printf '[]\n'; }
  zshlint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zshlint-shellcheck zshlint-custom
  bats_run_script "$ZSHLINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when neither sub-linter finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zshlint-shellcheck() { printf '[]\n'; }
  zshlint-custom()     { printf '[]\n'; }
  bats_mock zshlint-shellcheck zshlint-custom
  bats_run_script "$ZSHLINT" "$file"
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}
