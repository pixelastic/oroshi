#!/usr/bin/env bats

bats_load_library 'helper'

BATS_LINT_CUSTOM="${BATS_TEST_DIRNAME}/../bats-lint-custom"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 for clean file" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '@test "ok" { bats_run_function echo; }\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "outputs JSON with code noRunZsh for run zsh usage" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'run zsh -c "echo hello"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}

@test "exits 1 when rule finds a violation" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'run zsh -c "echo hello"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$status" -eq 1 ]]
}

@test "file field matches argument path" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'run zsh -c "echo hello"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$output" == *"\"file\":\"$file\""* ]]
}

@test "outputs valid JSON array" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '@test "ok" { bats_run_function echo; }\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}

@test "multiple violations appear in output array" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'run zsh -c "a"\nrun zsh -c "b"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$status" -eq 1 ]]
  run bash -c "jq 'length' <<< '$output'"
  [[ "$output" == '2' ]]
}

@test "bats-lint-disable on previous line suppresses violation" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '# bats-lint-disable noRunZsh\nrun zsh -c "echo"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "bats-lint-disable only suppresses the named rule" {
  local file="$BATS_TMP_DIR/test.bats"
  printf '# bats-lint-disable noRunZsh\nrun zsh -c "a"\nrun zsh -c "b"\n' >"$file"
  bats_run_script "$BATS_LINT_CUSTOM" "$file"
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}
