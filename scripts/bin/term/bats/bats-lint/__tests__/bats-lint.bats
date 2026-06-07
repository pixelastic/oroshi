#!/usr/bin/env bats

bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="${BATS_TEST_DIRNAME}/../bats-lint"
}

teardown() {
  bats_cleanup
}

@test "outputs [] and exits 0 when both linters return empty" {
  is-bats() { return 0; }
  bats_mock is-bats
  bats-lint-shellcheck() { printf '[]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "merges violations from both linters" {
  is-bats() { return 0; }
  bats_mock is-bats
  bats-lint-shellcheck() {
    printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'
  }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() {
    printf '[{"file":"f","line":2,"code":"noRunZsh","message":"m"}]\n'
  }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}

@test "exits non-zero when violations found" {
  is-bats() { return 0; }
  bats_mock is-bats
  bats-lint-shellcheck() {
    printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'
  }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -ne 0 ]]
}

@test "outputs valid JSON array" {
  is-bats() { return 0; }
  bats_mock is-bats
  bats-lint-shellcheck() { printf '[]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}

@test "outputs notBats violation for non-bats file, exits 1" {
  is-bats() { return 1; }
  bats_mock is-bats
  bats-lint-shellcheck() { printf '[{"code":"SC2086"}]\n'; }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[{"code":"noRunZsh"}]\n'; }
  bats_mock bats-lint-custom

  local file="$BATS_TMP_DIR/test.zsh"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$CURRENT" "$file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notBats"'* ]]
  [[ "$output" != *'"code":"SC2086"'* ]]
  [[ "$output" != *'"code":"noRunZsh"'* ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
}

@test "merges notBats with sub-linter violations for mixed input" {
  is-bats() {
    [[ "$1" == *.bats ]] && return 0
    return 1
  }
  bats_mock is-bats
  bats-lint-shellcheck() {
    printf '[{"file":"%s","code":"SC2086","line":1,"column":1,"message":"m"}]\n' "$1"
  }
  bats_mock bats-lint-shellcheck
  bats-lint-custom() { printf '[]\n'; }
  bats_mock bats-lint-custom

  local valid="$BATS_TMP_DIR/valid.bats"
  local invalid="$BATS_TMP_DIR/other.zsh"
  printf 'placeholder\n' >"$valid"
  printf 'placeholder\n' >"$invalid"
  bats_run_zsh "$CURRENT" "$valid" "$invalid"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notBats"'* ]]
  [[ "$output" == *'"code":"SC2086"'* ]]
}
