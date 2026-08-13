bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "merges custom rule output with shellcheck JSON into single array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "returns empty array and exit 0 for clean file" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "returns exit 1 when custom rule finds a violation" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
}

@test "merges output from both sub-linters when both have violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[{"code":2162}]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint $file"
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
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when only custom rules find violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when neither sub-linter finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint $file"
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}

@test "outputs notZsh violation for non-zsh file, exits 1" {
  is-zsh() { return 1; }
  zsh-lint-shellcheck() {
    printf 'called\n' >"$BATS_TMP_DIR/shellcheck_called"
    printf '[]\n'
  }
  zsh-lint-custom() {
    printf 'called\n' >"$BATS_TMP_DIR/custom_called"
    printf '[]\n'
  }
  bats_mock is-zsh zsh-lint-shellcheck zsh-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notZsh"'* ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
  [[ ! -f "$BATS_TMP_DIR/shellcheck_called" ]]
  [[ ! -f "$BATS_TMP_DIR/custom_called" ]]
}

@test "--fix: calls zsh-fix then runs lint check" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  zsh-fix() { printf 'called\n' >"$BATS_TMP_DIR/zsh_fix_called"; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --fix $file"
  [[ -f "$BATS_TMP_DIR/zsh_fix_called" ]]
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "--fix: violations surviving auto-format are reported, exit non-zero" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  zsh-fix() { :; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom() {
    printf '[{"code":"noManualArgParsing","level":"error","line":1,"message":"m"}]\n'
  }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --fix $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "--fix: corrects multiple mal-formatted files in one batch" {
  local file1="$BATS_TMP_DIR/one.zsh"
  local file2="$BATS_TMP_DIR/two.zsh"
  printf '# file one\n' > "$file1"
  printf '# file two\n' > "$file2"
  zsh-fix() { printf '%s\n' "$@" >"$BATS_TMP_DIR/zsh_fix_args"; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  local arguments="$(cat "$BATS_TMP_DIR/zsh_fix_args")"
  [[ "$arguments" == *"--in-place"* ]]
  [[ "$arguments" == *"one.zsh"* ]]
  [[ "$arguments" == *"two.zsh"* ]]
}

@test "without --fix: zsh-fix is not called" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  zsh-fix() { printf 'called\n' >"$BATS_TMP_DIR/zsh_fix_called"; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint $file"
  [[ ! -f "$BATS_TMP_DIR/zsh_fix_called" ]]
}

@test "merges notZsh with sub-linter violations for mixed input" {
  is-zsh() {
    [[ "$1" == *.zsh ]] && return 0
    return 1
  }
  zsh-lint-shellcheck() {
    printf '%s\n' "$@" >"$BATS_TMP_DIR/shellcheck_args"
    printf '[{"file":"%s","code":"SC2086","line":1,"column":1,"message":"m"}]\n' "$1"
  }
  zsh-lint-custom() { printf '[]\n'; }
  bats_mock is-zsh zsh-lint-shellcheck zsh-lint-custom

  local valid="$BATS_TMP_DIR/valid.zsh"
  local invalid="$BATS_TMP_DIR/other.bats"
  printf 'placeholder\n' >"$valid"
  printf 'placeholder\n' >"$invalid"
  bats_run_zsh "zsh-lint $valid $invalid"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notZsh"'* ]]
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$(cat "$BATS_TMP_DIR/shellcheck_args")" == "$valid" ]]
  [[ "$(cat "$BATS_TMP_DIR/shellcheck_args")" != *"$invalid"* ]]
}
