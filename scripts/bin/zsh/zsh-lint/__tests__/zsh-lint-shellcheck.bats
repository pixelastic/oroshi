#!/usr/bin/env bats
# shellcheck disable=SC2016  # $foo in single-quoted printf is intentional

bats_load_library 'helper'

ZSH_LINT_SC="${BATS_TEST_DIRNAME}/../zsh-lint-shellcheck"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSH_LINT_SC" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "excludes SC2086 — unquoted variable produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'echo $foo\n' > "$file"
  run zsh "$ZSH_LINT_SC" "$file"
  [[ "$output" == '[]' ]]
}

@test "excludes SC2155 — local with command substitution produces []" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'local foo="$(date)"\n' > "$file"
  run zsh "$ZSH_LINT_SC" "$file"
  [[ "$output" == '[]' ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean\n' > "$file"
  run zsh "$ZSH_LINT_SC" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
