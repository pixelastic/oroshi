bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Mock sub-linters: shellcheck reports one violation on the first file, others are clean
mock_one_violation() {
  zsh-lint-shellcheck() {
    printf '[{"file":"%s","code":"SC2086","level":"info","line":3,"column":7,"endLine":3,"endColumn":9,"message":"Double quote to prevent globbing"}]\n' "$1"
  }
  zsh-lint-syntax() { printf '[]\n'; }
  zsh-lint-custom() { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-syntax zsh-lint-custom
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "dirty file: outputs stylish format, exits 1" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  mock_one_violation
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
  # File header line
  [[ "${lines[0]}" == *"test.zsh" ]]
  # Violation line: line:col  level  message  code
  [[ "${lines[1]}" == "  3:7  info  Double quote to prevent globbing  SC2086" ]]
  [[ "$output" != *'"code"'* ]]
}

@test "stylish output outside a git repo: paths relative to current directory" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  mock_one_violation
  bats_run_zsh "cd $BATS_TMP_DIR && zsh-lint test.zsh"
  [[ "$status" -eq 1 ]]
  [[ "${lines[0]}" == "test.zsh" ]]
}

@test "dirty file: real custom rule violation reported in stylish format" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"noManualArgParsing"* ]]
}

# --- JSON output (--json) ---

@test "--json: merges custom rule output with shellcheck JSON into single array" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf 'case "$1" in\n  --foo) foo=1 ;;\nesac\n' > "$file"
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"noManualArgParsing"'* ]]
}

@test "--json: clean file outputs empty array, exits 0" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "--json: dirty file outputs array of violation objects, exits 1" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  mock_one_violation
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$file" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "SC2086" ]]
}

@test "--json: merges output from all sub-linters when all have violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[{"code":2162}]\n'; }
  zsh-lint-syntax()     { printf '[{"code":"syntaxError"}]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-syntax zsh-lint-custom
  bats_run_zsh "zsh-lint --json $file"
  [[ "$output" == *'"code":2162'* ]]
  [[ "$output" == *'"code":"syntaxError"'* ]]
  [[ "$output" == *'"code":90005'* ]]
  [[ "$status" -eq 1 ]]
}

@test "--json: exits 1 when only shellcheck finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[{"code":2162}]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 1 ]]
}

@test "--json: exits 1 when only custom rules find violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[{"code":90005}]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 1 ]]
}

@test "--json: exits 0 when no sub-linter finds violations" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --json $file"
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}

@test "--json: lints autoload function given by bare filename from its directory" {
  local dir="$BATS_TMP_DIR/functions/autoload/demo"
  mkdir -p "$dir"
  printf '# clean autoload function\nsetopt local_options err_return\n' >"$dir/demo-func"
  bats_run_zsh "cd $dir && zsh-lint --json demo-func"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

# --- Argument handling ---

@test "no arguments: errors, exits 1" {
  bats_run_zsh "zsh-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}

@test "expands arguments via file-expand --filter is-zsh" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  file-expand() {
    printf '%s\n' "$@" > "$BATS_TMP_DIR/expand_args"
    printf '%s\n' "$BATS_TMP_DIR/test.zsh"
  }
  bats_mock file-expand
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 0 ]]
  local arguments="$(cat "$BATS_TMP_DIR/expand_args")"
  [[ "$arguments" == *"--filter"* ]]
  [[ "$arguments" == *"is-zsh"* ]]
}

@test "non-zsh files are silently dropped" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' > "$file"
  zsh-lint-shellcheck() {
    printf 'called\n' > "$BATS_TMP_DIR/shellcheck_called"
    printf '[]\n'
  }
  bats_mock zsh-lint-shellcheck
  bats_run_zsh "zsh-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -f "$BATS_TMP_DIR/shellcheck_called" ]]
}

@test "--json: non-zsh files are silently dropped, outputs empty array" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' > "$file"
  bats_run_zsh "zsh-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "mixed input: only zsh files are passed to sub-linters" {
  local valid="$BATS_TMP_DIR/valid.zsh"
  local invalid="$BATS_TMP_DIR/other.bats"
  printf 'placeholder\n' > "$valid"
  printf 'placeholder\n' > "$invalid"
  zsh-lint-shellcheck() {
    printf '%s\n' "$@" > "$BATS_TMP_DIR/shellcheck_args"
    printf '[]\n'
  }
  zsh-lint-syntax() { printf '[]\n'; }
  zsh-lint-custom() { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-syntax zsh-lint-custom
  bats_run_zsh "zsh-lint --json $valid $invalid"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/shellcheck_args")" == "$valid" ]]
}

# --- Directory expansion ---

@test "directory input: expands recursively, lints all zsh files" {
  mkdir -p "$BATS_TMP_DIR/src/nested"
  printf '# one\n' > "$BATS_TMP_DIR/src/one.zsh"
  printf '# two\n' > "$BATS_TMP_DIR/src/nested/two.zsh"
  printf 'not zsh\n' > "$BATS_TMP_DIR/src/readme.md"
  mock_one_violation
  bats_run_zsh "zsh-lint $BATS_TMP_DIR/src/"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"SC2086"* ]]
}

@test "--json directory input: lints all zsh files, outputs JSON" {
  mkdir -p "$BATS_TMP_DIR/src/nested"
  printf '# one\n' > "$BATS_TMP_DIR/src/one.zsh"
  printf '# two\n' > "$BATS_TMP_DIR/src/nested/two.zsh"
  printf 'not zsh\n' > "$BATS_TMP_DIR/src/readme.md"
  zsh-lint-shellcheck() {
    local file
    for file in "$@"; do
      printf '{"file":"%s","code":"SC2086","level":"info","line":1,"column":1,"message":"m"}\n' "$file"
    done | jq --compact-output --slurp '.'
  }
  zsh-lint-syntax() { printf '[]\n'; }
  zsh-lint-custom() { printf '[]\n'; }
  bats_mock zsh-lint-shellcheck zsh-lint-syntax zsh-lint-custom
  bats_run_zsh "zsh-lint --json $BATS_TMP_DIR/src/"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 2 ]]
  [[ "$output" == *"one.zsh"* ]]
  [[ "$output" == *"two.zsh"* ]]
  [[ "$output" != *"readme.md"* ]]
}

# --- Fix mode ---

@test "--fix: calls zsh-fix then reports stylish" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-fix() { printf 'called\n' > "$BATS_TMP_DIR/zsh_fix_called"; }
  bats_mock zsh-fix
  mock_one_violation
  bats_run_zsh "zsh-lint --fix $file"
  [[ -f "$BATS_TMP_DIR/zsh_fix_called" ]]
  [[ "$status" -eq 1 ]]
  [[ "${lines[1]}" == "  3:7  info  Double quote to prevent globbing  SC2086" ]]
}

@test "--fix --json: calls zsh-fix then reports JSON" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# test\n' > "$file"
  zsh-fix() { printf 'called\n' > "$BATS_TMP_DIR/zsh_fix_called"; }
  bats_mock zsh-fix
  mock_one_violation
  bats_run_zsh "zsh-lint --fix --json $file"
  [[ -f "$BATS_TMP_DIR/zsh_fix_called" ]]
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "SC2086" ]]
}

@test "--fix: clean after format, no output, exits 0" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  zsh-fix() { :; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--fix: corrects multiple mal-formatted files in one batch" {
  local file1="$BATS_TMP_DIR/one.zsh"
  local file2="$BATS_TMP_DIR/two.zsh"
  printf '# file one\n' > "$file1"
  printf '# file two\n' > "$file2"
  zsh-fix() { printf '%s\n' "$@" > "$BATS_TMP_DIR/zsh_fix_args"; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint --fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  local arguments="$(cat "$BATS_TMP_DIR/zsh_fix_args")"
  [[ "$arguments" != *"--in-place"* ]]
  [[ "$arguments" == *"one.zsh"* ]]
  [[ "$arguments" == *"two.zsh"* ]]
}

@test "--fix: zsh-fix not called when no zsh files" {
  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' > "$file"
  zsh-fix() { printf 'called\n' > "$BATS_TMP_DIR/zsh_fix_called"; }
  bats_mock zsh-fix
  bats_run_zsh "zsh-lint --fix $file"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/zsh_fix_called" ]]
}

@test "without --fix: zsh-fix is not called" {
  local file="$BATS_TMP_DIR/test.zsh"
  printf '# clean zsh file\n' > "$file"
  zsh-fix() { printf 'called\n' > "$BATS_TMP_DIR/zsh_fix_called"; }
  zsh-lint-shellcheck() { printf '[]\n'; }
  zsh-lint-custom()     { printf '[]\n'; }
  bats_mock zsh-fix zsh-lint-shellcheck zsh-lint-custom
  bats_run_zsh "zsh-lint $file"
  [[ ! -f "$BATS_TMP_DIR/zsh_fix_called" ]]
}
