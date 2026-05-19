#!/usr/bin/env bats
# shellcheck disable=SC2016  # $foo in single-quoted printf is intentional

load '../../../__tests__/helper'

ZSHLINT_SC="${BATS_TEST_DIRNAME}/../zshlint-shellcheck"

@test "outputs [] and exits 0 for clean file" {
  local file="$(bats_tmp)/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_SC" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "excludes SC2086 — unquoted variable produces []" {
  local file="$(bats_tmp)/test.zsh"
  printf 'echo $foo\n' > "$file"
  run zsh "$ZSHLINT_SC" "$file"
  [[ "$output" == '[]' ]]
}

@test "excludes SC2155 — local with command substitution produces []" {
  local file="$(bats_tmp)/test.zsh"
  printf 'local foo="$(date)"\n' > "$file"
  run zsh "$ZSHLINT_SC" "$file"
  [[ "$output" == '[]' ]]
}

@test "outputs valid JSON array" {
  local file="$(bats_tmp)/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSHLINT_SC" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
