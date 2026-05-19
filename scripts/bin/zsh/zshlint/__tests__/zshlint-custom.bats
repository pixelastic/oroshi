#!/usr/bin/env bats
# shellcheck disable=SC2016  # $1 in single-quoted printf is intentional

load '../../../__tests__/helper'

ZSHLINT_CUSTOM="${BATS_TEST_DIRNAME}/../zshlint-custom"

@test "outputs [] and exits 0 for clean file" {
  local file="$(bats_tmp)/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "outputs JSON with code 90005 for case \"\$1\" pattern" {
  local file="$(bats_tmp)/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$output" == *'"code":90005'* ]]
}

@test "exits 1 when custom rule finds a violation" {
  local file="$(bats_tmp)/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  [[ "$status" -eq 1 ]]
}

@test "outputs valid JSON array" {
  local file="$(bats_tmp)/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_CUSTOM" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
