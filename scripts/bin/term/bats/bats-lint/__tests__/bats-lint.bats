#!/usr/bin/env bats

bats_load_library 'helper'

BATS_LINT="${BATS_TEST_DIRNAME}/../bats-lint"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '@test "ok" { bats_run_function echo; }\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "merges violations from both shellcheck and custom rules" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'echo $HOME\nrun zsh -c "echo"\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}

@test "exits non-zero when violations found" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'run zsh -c "echo hello"\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$status" -ne 0 ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '@test "ok" { bats_run_function echo; }\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
