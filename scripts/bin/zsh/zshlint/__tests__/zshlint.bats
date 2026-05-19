#!/usr/bin/env bats
# shellcheck disable=SC2016  # $1 in single-quoted printf strings is intentional

load '../../../__tests__/helper'

ZSHLINT="${BATS_TEST_DIRNAME}/../zshlint"

@test "merges custom rule output with shellcheck JSON into single array" {
  local file="$(bats_tmp)/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$output" == *'"code":90005'* ]]
}

@test "returns empty array and exit 0 for clean file" {
  local file="$(bats_tmp)/test.zsh"
  printf '# clean zsh file\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "returns exit 1 when custom rule finds a violation" {
  local file="$(bats_tmp)/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  run zsh "$ZSHLINT" "$file"
  [[ "$status" -eq 1 ]]
}
