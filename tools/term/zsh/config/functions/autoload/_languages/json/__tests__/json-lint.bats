bats_load_library 'helper'

## Mocked eslint toolchain; tests control output by writing to
## $BATS_TMP_DIR/eslint_{stylish,json}_output before calling json-lint
setup() {
  bats_tmp_dir

  # Default clean output files — tests override as needed
  printf '' > "$BATS_TMP_DIR/eslint_stylish_output"
  printf '[]' > "$BATS_TMP_DIR/eslint_json_output"

  # Prevent config resolution from traversing the real filesystem
  yarn-root() { return 1; }
  # Record json-fix calls for --fix tests
  json-fix() { printf '%s\n' "$*" >> "$BATS_TMP_DIR/fix_calls"; }
  # eslint_d returns stylish or JSON output based on --format json flag
  eslint_d() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/eslint_calls"
    for arg in "$@"; do
      [[ "$arg" == "json" ]] && { cat "$BATS_TMP_DIR/eslint_json_output"; return 0; }
    done
    cat "$BATS_TMP_DIR/eslint_stylish_output"
  }
  bats_mock yarn-root json-fix eslint_d
}

@test "outputs stylish violations for a file with lint errors" {
  local file="$BATS_TMP_DIR/bad.json"
  echo '{}' > "$file"

  printf '%s' "$file
  1:8  error  Trailing comma  json/trailing-comma

1 problem (1 error, 0 warnings)" > "$BATS_TMP_DIR/eslint_stylish_output"

  bats_run_zsh "json-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Trailing comma"* ]]
}

@test "outputs nothing for a clean file (exit 0)" {
  local file="$BATS_TMP_DIR/clean.json"
  echo '{}' > "$file"

  bats_run_zsh "json-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--json outputs unified schema array for a file with lint errors" {
  local file="$BATS_TMP_DIR/bad.json"
  echo '{}' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[{"ruleId":"json/trailing-comma","severity":2,"message":"Trailing comma","line":1,"column":8}],"errorCount":1,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "json-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "json/trailing-comma" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "8" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == "Trailing comma" ]]
}

@test "--json outputs [] for a clean file" {
  local file="$BATS_TMP_DIR/clean.json"
  echo '{}' > "$file"

  printf '%s' '[{"filePath":"'"$file"'","messages":[],"errorCount":0,"warningCount":0}]' > "$BATS_TMP_DIR/eslint_json_output"

  bats_run_zsh "json-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--fix formats file then reports remaining violations" {
  local file="$BATS_TMP_DIR/bad.json"
  echo '{}' > "$file"

  printf '%s' "$file
  1:8  error  Remaining issue  json/some-rule

1 problem (1 error, 0 warnings)" > "$BATS_TMP_DIR/eslint_stylish_output"

  bats_run_zsh "json-lint --fix $file"
  [[ "$status" -eq 1 ]]
  # json-fix was called
  [[ -f "$BATS_TMP_DIR/fix_calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/fix_calls")" == *"$file"* ]]
  # Remaining violations reported
  [[ "$output" == *"Remaining issue"* ]]
}

@test "exits 1 when violations found" {
  local file="$BATS_TMP_DIR/bad.json"
  echo '{}' > "$file"

  printf '%s' "violation output" > "$BATS_TMP_DIR/eslint_stylish_output"

  bats_run_zsh "json-lint $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 when file is clean" {
  local file="$BATS_TMP_DIR/clean.json"
  echo '{}' > "$file"

  bats_run_zsh "json-lint $file"
  [[ "$status" -eq 0 ]]
}

@test "expands directories and lints all .json files inside" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo '{}' > "$dir/a.json"
  echo '{}' > "$dir/b.json"

  bats_run_zsh "json-lint $dir"
  [[ "$status" -eq 0 ]]
  # eslint_d was called with both files
  [[ -f "$BATS_TMP_DIR/eslint_calls" ]]
  local calls="$(cat "$BATS_TMP_DIR/eslint_calls")"
  [[ "$calls" == *"a.json"* ]]
  [[ "$calls" == *"b.json"* ]]
}

@test "skips non-json files in directory expansion" {
  local dir="$BATS_TMP_DIR/src"
  mkdir -p "$dir"
  echo '{}' > "$dir/a.json"
  echo 'hello' > "$dir/readme.txt"

  bats_run_zsh "json-lint $dir"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/eslint_calls")"
  [[ "$calls" == *"a.json"* ]]
  [[ "$calls" != *"readme.txt"* ]]
}

@test "errors when no files provided" {
  bats_run_zsh "json-lint"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}

@test "runs eslint_d from files common ancestor when no project root" {
  local file="$BATS_TMP_DIR/clean.json"
  echo '{}' > "$file"

  eslint_d() {
    pwd > "$BATS_TMP_DIR/eslint_cwd"
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/eslint_calls"
    cat "$BATS_TMP_DIR/eslint_stylish_output"
  }
  bats_mock eslint_d
  bats_disable_worktree_aware

  bats_run_zsh "cd /tmp && json-lint $file"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/eslint_cwd" ]]
  local cwd="$(cat "$BATS_TMP_DIR/eslint_cwd")"
  [[ "$cwd" == "$BATS_TMP_DIR" ]]
}

@test "reports parsing errors for invalid JSON outside any project" {
  local file="$BATS_TMP_DIR/bad.json"
  echo '{invalid' > "$file"

  printf '%s' "$file
  1:1  error  Parsing error: Unexpected token i  json/*

1 problem (1 error, 0 warnings)" > "$BATS_TMP_DIR/eslint_stylish_output"

  eslint_d() {
    pwd > "$BATS_TMP_DIR/eslint_cwd"
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/eslint_calls"
    cat "$BATS_TMP_DIR/eslint_stylish_output"
  }
  bats_mock eslint_d
  bats_disable_worktree_aware

  bats_run_zsh "cd /tmp && json-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Parsing error"* ]]
  local cwd="$(cat "$BATS_TMP_DIR/eslint_cwd")"
  [[ "$cwd" == "$BATS_TMP_DIR" ]]
}

@test "runs eslint from project root when file has a project root" {
  mkdir -p "$BATS_TMP_DIR/myproject"
  local file="$BATS_TMP_DIR/myproject/config.json"
  echo '{}' > "$file"

  yarn-root() { echo "$BATS_TMP_DIR/myproject"; }
  eslint_d() {
    pwd > "$BATS_TMP_DIR/eslint_cwd"
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/eslint_calls"
    cat "$BATS_TMP_DIR/eslint_stylish_output"
  }
  bats_mock yarn-root eslint_d
  bats_disable_worktree_aware

  bats_run_zsh "cd /tmp && json-lint $file"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/eslint_cwd" ]]
  local cwd="$(cat "$BATS_TMP_DIR/eslint_cwd")"
  [[ "$cwd" == "$BATS_TMP_DIR/myproject" ]]
}
