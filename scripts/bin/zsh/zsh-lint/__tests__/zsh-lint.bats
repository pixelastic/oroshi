#!/usr/bin/env bats

bats_load_library 'helper'

setup() {
  ZSH_LINT="${BATS_TEST_DIRNAME}/../zsh-lint"
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "merges custom rule output with shellcheck JSON into single array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "returns empty array and exit 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "returns exit 1 when custom rule finds a violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "merges output from both sub-linters when both have violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[{"code":2162}]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$output" == *'"code":2162'* ]]
  [[ "$output" == *'"code":90005'* ]]
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when only shellcheck finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[{"code":2162}]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when only custom rules find violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when neither sub-linter finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}

@test "outputs notZsh violation for non-zsh file, exits 1" {
  is-zsh() { return 1; }
  bats_mock is-zsh
  zsh-lint-shellcheck() {
    printf 'called\n' >"$BATS_TMP_DIR/shellcheck_called"
    printf '[]\n'
  }
  bats_mock zsh-lint-shellcheck
  zsh-lint-custom() {
    printf 'called\n' >"$BATS_TMP_DIR/custom_called"
    printf '[]\n'
  }
  bats_mock zsh-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "$ZSH_LINT" "$file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notZsh"'* ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
  [[ ! -f "$BATS_TMP_DIR/shellcheck_called" ]]
  [[ ! -f "$BATS_TMP_DIR/custom_called" ]]
}

@test "merges notZsh with sub-linter violations for mixed input" {
  is-zsh() {
    [[ "$1" == *.zsh ]] && return 0
    return 1
  }
  bats_mock is-zsh
  zsh-lint-shellcheck() {
    printf '%s\n' "$@" >"$BATS_TMP_DIR/shellcheck_args"
    printf '[{"file":"%s","code":"SC2086","line":1,"column":1,"message":"m"}]\n' "$1"
  }
  bats_mock zsh-lint-shellcheck
  zsh-lint-custom() { printf '[]\n'; }
  bats_mock zsh-lint-custom

  local valid="$BATS_TMP_DIR/valid.zsh"
  local invalid="$BATS_TMP_DIR/other.bats"
  printf 'placeholder\n' >"$valid"
  printf 'placeholder\n' >"$invalid"
  bats_run_zsh "$ZSH_LINT" "$valid" "$invalid"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notZsh"'* ]]
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$(cat "$BATS_TMP_DIR/shellcheck_args")" == "$valid" ]]
  [[ "$(cat "$BATS_TMP_DIR/shellcheck_args")" != *"$invalid"* ]]
}
