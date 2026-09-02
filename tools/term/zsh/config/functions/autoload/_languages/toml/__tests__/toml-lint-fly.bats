bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # fly is not available by default
  fly() { return 1; }
  bats_mock fly
}

# --- Core behavior ---

@test "fly.toml with warnings: outputs unified JSON array" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  fly() {
    printf 'WARN some warning row 2 column 5\n'
    return 0
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "fly-validate" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "warn" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "2" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "5" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == *"some warning"* ]]
}

@test "fly.toml with errors: level is error" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  fly() {
    printf 'Error: something broke row 3 column 1\n'
    return 0
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].level')" == "error" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].line')" == "3" ]]
}

@test "fly.toml with no diagnostics: outputs []" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  fly() {
    printf '✓ Configuration is valid\n'
    return 0
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "fly auth failure: outputs [] and warns on stderr" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  fly() {
    echo "Error: not authenticated" >&2
    return 1
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  local jsonOutput="$(printf '%s' "$output" | grep -v '^Warning:')"
  [[ "$jsonOutput" == "[]" ]]
}

@test "non-fly.toml file: outputs []" {
  local file="$BATS_TMP_DIR/config.toml"
  echo 'key = "value"' > "$file"

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "multiple files: only fly.toml files are checked" {
  local flyFile="$BATS_TMP_DIR/fly.toml"
  local otherFile="$BATS_TMP_DIR/config.toml"
  echo 'app = "myapp"' > "$flyFile"
  echo 'key = "value"' > "$otherFile"

  fly() {
    printf 'WARN some warning row 2 column 5\n'
    return 0
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $otherFile $flyFile"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$flyFile" ]]
}

@test "multiple files with no fly.toml: outputs []" {
  local file1="$BATS_TMP_DIR/a.toml"
  local file2="$BATS_TMP_DIR/b.toml"
  echo 'a = 1' > "$file1"
  echo 'b = 2' > "$file2"

  bats_run_zsh "toml-lint-fly $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "warning without row/column: defaults to line 1, column 1" {
  local file="$BATS_TMP_DIR/fly.toml"
  echo 'app = "myapp"' > "$file"

  fly() {
    printf 'WARN missing something important\n'
    return 0
  }
  bats_mock fly

  bats_run_zsh "toml-lint-fly $file"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].line')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].column')" == "1" ]]
}
