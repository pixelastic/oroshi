#!/usr/bin/env bats
# shellcheck disable=SC2016  # $1 in single-quoted printf is intentional

bats_load_library 'helper'

ZSHLINT_CUSTOM="${BATS_TEST_DIRNAME}/../zshlint-custom"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "outputs JSON with code noManualArgParsing for case \"\$1\" pattern" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "exits 1 when custom rule finds a violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$status" -eq 1 ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
