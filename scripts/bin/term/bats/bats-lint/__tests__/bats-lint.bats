#!/usr/bin/env bats

bats_load_library 'helper'

BATS_LINT="${BATS_TEST_DIRNAME}/../bats-lint"

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 when both linters return empty" {
  bats-lint-shellcheck() { printf '[]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "merges violations from both linters" {
  bats-lint-shellcheck() { printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[{"file":"f","line":2,"code":"noRunZsh","message":"m"}]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}

@test "exits non-zero when violations found" {
  bats-lint-shellcheck() { printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  [[ "$status" -ne 0 ]]
}

@test "outputs valid JSON array" {
  bats-lint-shellcheck() { printf '[]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_script "$BATS_LINT" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}
