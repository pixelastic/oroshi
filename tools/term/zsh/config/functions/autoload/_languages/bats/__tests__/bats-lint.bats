bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  is-bats() { return 0; }
  bats-lint-shellcheck() { printf '[]\n'; }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "no files: no output, exits 0" {
  bats_run_zsh "bats-lint"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "dirty file: outputs stylish format, exits 1" {
  is-bats() { return 0; }
  bats-lint-shellcheck() {
    printf '[{"file":"%s","line":3,"column":7,"level":"error","code":"SC2086","message":"Quote it"}]\n' "$1"
  }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "cd $BATS_TMP_DIR && bats-lint test.bats"
  [[ "$status" -eq 1 ]]
  # File header line, relative to the current directory outside a git repo
  [[ "${lines[0]}" == "test.bats" ]]
  # Violation line: line:col  level  message  code
  [[ "${lines[1]}" == "  3:7  error  Quote it  SC2086" ]]
  [[ "$output" != *'"code"'* ]]
}

# --- JSON output (--json) ---

@test "--json: outputs [] and exits 0 when both linters return empty" {
  is-bats() { return 0; }
  bats-lint-shellcheck() { printf '[]\n'; }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "--json: merges violations from both linters" {
  is-bats() { return 0; }
  bats-lint-shellcheck() {
    printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'
  }
  bats-lint-custom() {
    printf '[{"file":"f","line":2,"code":"noRunZsh","message":"m"}]\n'
  }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint --json $file"
  [[ "$output" == *'"code":"SC2086"'* ]]
  [[ "$output" == *'"code":"noRunZsh"'* ]]
}

@test "--json: exits non-zero when violations found" {
  is-bats() { return 0; }
  bats-lint-shellcheck() {
    printf '[{"file":"f","line":1,"column":1,"code":"SC2086","message":"m"}]\n'
  }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint --json $file"
  [[ "$status" -ne 0 ]]
}

@test "--json: outputs valid JSON array" {
  is-bats() { return 0; }
  bats-lint-shellcheck() { printf '[]\n'; }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.bats"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint --json $file"
  run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
  [[ "$output" == 'true' ]]
}

@test "--json: outputs notBats violation for non-bats file, exits 1" {
  is-bats() { return 1; }
  bats-lint-shellcheck() { printf '[{"code":"SC2086"}]\n'; }
  bats-lint-custom() { printf '[{"code":"noRunZsh"}]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local file="$BATS_TMP_DIR/test.zsh"
  printf 'placeholder\n' >"$file"
  bats_run_zsh "bats-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notBats"'* ]]
  [[ "$output" != *'"code":"SC2086"'* ]]
  [[ "$output" != *'"code":"noRunZsh"'* ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
}

@test "--json: merges notBats with sub-linter violations for mixed input" {
  is-bats() {
    [[ "$1" == *.bats ]] && return 0
    return 1
  }
  bats-lint-shellcheck() {
    printf '[{"file":"%s","code":"SC2086","line":1,"column":1,"message":"m"}]\n' "$1"
  }
  bats-lint-custom() { printf '[]\n'; }
  bats_mock is-bats bats-lint-shellcheck bats-lint-custom

  local valid="$BATS_TMP_DIR/valid.bats"
  local invalid="$BATS_TMP_DIR/other.zsh"
  printf 'placeholder\n' >"$valid"
  printf 'placeholder\n' >"$invalid"
  bats_run_zsh "bats-lint --json $valid $invalid"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *'"code":"notBats"'* ]]
  [[ "$output" == *'"code":"SC2086"'* ]]
}
