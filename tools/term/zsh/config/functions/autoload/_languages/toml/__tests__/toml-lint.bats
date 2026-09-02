bats_load_library 'helper'

## Mock underlying binaries so the sourced __lib helpers run but don't invoke real tools
## Tests control eslint output by writing to $BATS_TMP_DIR/eslint_json_output
setup() {
  bats_tmp_dir

  # Default clean eslint output (raw eslint format)
  printf '%s' '[{"filePath":"clean.toml","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  # Prevent config resolution from traversing the real filesystem
  yarn-root() { return 1; }
  # Record toml-fix calls for --fix tests
  toml-fix() { printf '%s\n' "$*" >> "$BATS_TMP_DIR/fix_calls"; }
  # eslint_d returns stylish or JSON output based on --format json flag
  eslint_d() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/eslint_calls"
    for arg in "$@"; do
      [[ "$arg" == "json" ]] && { cat "$BATS_TMP_DIR/eslint_json_output"; return 0; }
    done
    cat "$BATS_TMP_DIR/eslint_stylish_output"
  }
  # toml-lint-fly returns no diagnostics by default
  toml-lint-fly() { printf '[]\n'; }
  bats_mock yarn-root toml-fix eslint_d toml-lint-fly
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/clean.toml"
  echo 'key = "value"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "file with violations: grouped stylish output, exits 1" {
  local file="$BATS_TMP_DIR/bad.toml"
  echo 'key = "value"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[{"ruleId":"toml/comma","severity":2,"message":"Trailing comma","line":1,"column":8}],"errorCount":1,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"bad.toml"* ]]
  [[ "$output" == *"1:8"* ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Trailing comma"* ]]
  [[ "$output" == *"toml/comma"* ]]
}

@test "multiple files: violations grouped by file" {
  local file1="$BATS_TMP_DIR/a.toml"
  local file2="$BATS_TMP_DIR/b.toml"
  echo 'key = 1' > "$file1"
  echo 'key = 2' > "$file2"

  printf '%s' '[{"filePath":"'"$file1"'","messages":[{"ruleId":"toml/rule-a","severity":2,"message":"error in a","line":1,"column":1}],"errorCount":1,"warningCount":0},{"filePath":"'"$file2"'","messages":[{"ruleId":"toml/rule-b","severity":1,"message":"error in b","line":2,"column":3}],"errorCount":0,"warningCount":1}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"a.toml"* ]]
  [[ "$output" == *"b.toml"* ]]
  # Blank line separates file groups
  local lineCount="$(printf '%s\n' "$output" | wc -l)"
  [[ "$lineCount" -ge 5 ]]
}

# --- JSON output (--json) ---

@test "--json on clean file: outputs [], exits 0" {
  local file="$BATS_TMP_DIR/clean.toml"
  echo 'key = "value"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--json on file with violations: array of unified objects, exits 1" {
  local file="$BATS_TMP_DIR/bad.toml"
  echo 'key = "value"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[{"ruleId":"toml/comma","severity":2,"message":"Trailing comma","line":1,"column":8}],"errorCount":1,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "toml/comma" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "8" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == "Trailing comma" ]]
}

# --- Fix mode ---

@test "--fix calls toml-fix first then reports fewer violations" {
  local file="$BATS_TMP_DIR/bad.toml"
  echo 'key = "value"' > "$file"

  # toml-fix reduces violations: eslint returns 2 initially, 1 after fix
  toml-fix() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/fix_calls"
    # After fix, switch to fewer violations
    printf '%s' '[{"filePath":"'"$file"'","messages":[{"ruleId":"toml/unfixable","severity":2,"message":"Remaining issue","line":1,"column":1}],"errorCount":1,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"
  }
  bats_mock toml-fix

  # Before fix: two violations
  printf '%s' '[{"filePath":"'"$file"'","messages":[{"ruleId":"toml/fixable","severity":2,"message":"Fixable issue","line":1,"column":1},{"ruleId":"toml/unfixable","severity":2,"message":"Remaining issue","line":1,"column":1}],"errorCount":2,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "toml-lint --fix --json $file"
  [[ "$status" -eq 1 ]]
  # toml-fix was called
  [[ -f "$BATS_TMP_DIR/fix_calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/fix_calls")" == *"$file"* ]]
  # Only 1 remaining violation (reduced from 2)
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].message')" == "Remaining issue" ]]
}

# --- fly.toml integration ---

@test "fly.toml merges toml-lint-fly diagnostics with eslint results" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  # toml-lint-fly returns a diagnostic
  toml-lint-fly() {
    printf '[{"file":"%s","code":"fly-validate","level":"warn","line":2,"column":5,"message":"some warning"}]\n' "$1"
  }
  bats_mock toml-lint-fly

  bats_run_zsh "toml-lint --json $file"
  local flyItem="$(printf '%s' "$output" | jq '[.[] | select(.code == "fly-validate")]')"
  [[ "$(printf '%s' "$flyItem" | jq 'length')" -ge 1 ]]
  [[ "$(printf '%s' "$flyItem" | jq -r '.[0].line')" == "2" ]]
  [[ "$(printf '%s' "$flyItem" | jq -r '.[0].column')" == "5" ]]
}

@test "non-fly.toml: toml-lint-fly returns [] and no fly diagnostics" {
  local file="$BATS_TMP_DIR/config.toml"
  echo 'key = "value"' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  # toml-lint-fly records calls
  toml-lint-fly() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/fly_lint_calls"
    printf '[]\n'
  }
  bats_mock toml-lint-fly

  bats_run_zsh "toml-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
  # toml-lint-fly was still called (it decides internally to skip)
  [[ -f "$BATS_TMP_DIR/fly_lint_calls" ]]
}

# --- Argument handling ---

@test "directory argument expands to .toml files" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo 'a = 1' > "$dir/a.toml"
  echo 'b = 2' > "$dir/b.toml"

  bats_run_zsh "toml-lint $dir"
  [[ "$status" -eq 0 ]]
  # eslint_d was called with both files
  [[ -f "$BATS_TMP_DIR/eslint_calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/eslint_calls")"
  [[ "$calls" == *"a.toml"* ]]
  [[ "$calls" == *"b.toml"* ]]
}

@test "non-TOML files in arguments are silently skipped" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo 'a = 1' > "$dir/a.toml"
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "toml-lint $dir"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/eslint_calls")"
  [[ "$calls" == *"a.toml"* ]]
  [[ "$calls" != *"readme.txt"* ]]
}

@test "no files provided: errors with exit 1" {
  bats_run_zsh "toml-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}
