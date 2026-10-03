bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/clean.py"
  printf 'x = 1\n' > "$file"

  bats_run_zsh "python-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "dirty file: outputs stylish format and exits 1" {
  local file="$BATS_TMP_DIR/dirty.py"
  printf 'import os\n' > "$file"

  bats_run_zsh "python-lint $file"
  [[ "$status" -eq 1 ]]
  # File header line
  [[ "$output" == *"$file"* ]]
  # Violation line: line:column  level  message  code
  [[ "$output" == *"1:8  error  "* ]]
  [[ "$output" == *"imported but unused"* ]]
  [[ "$output" == *"F401"* ]]
}

@test "multiple files: violations grouped by file, separated by a blank line" {
  local file1="$BATS_TMP_DIR/a.py"
  local file2="$BATS_TMP_DIR/b.py"
  printf 'import os\n' > "$file1"
  printf 'import sys\n' > "$file2"

  bats_run_zsh "python-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"$file1"* ]]
  [[ "$output" == *"$file2"* ]]
  [[ "$output" == *$'\n\n'* ]]
  # One header, one violation per file
  [[ "$(printf '%s\n' "$output" | wc -l)" -eq 5 ]]
}

@test "stylish output: file header is relative to the working directory root" {
  printf 'import os\n' > "$BATS_TMP_DIR/dirty.py"

  bats_run_zsh "cd $BATS_TMP_DIR && python-lint dirty.py"
  [[ "$status" -eq 1 ]]
  [[ "${output%%$'\n'*}" == "dirty.py" ]]
}

@test "clean file next to a dirty file: only the dirty file is reported" {
  local file1="$BATS_TMP_DIR/clean.py"
  local file2="$BATS_TMP_DIR/dirty.py"
  printf 'x = 1\n' > "$file1"
  printf 'import os\n' > "$file2"

  bats_run_zsh "python-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$output" != *"clean.py"* ]]
  [[ "$output" == *"dirty.py"* ]]
}

# --- File expansion ---

@test "directory input: lints the Python files below it" {
  mkdir -p "$BATS_TMP_DIR/pkg/sub"
  printf 'import os\n' > "$BATS_TMP_DIR/pkg/a.py"
  printf 'import sys\n' > "$BATS_TMP_DIR/pkg/sub/b.py"

  bats_run_zsh "python-lint --json $BATS_TMP_DIR/pkg"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "2" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[].file' | sort)" == "$BATS_TMP_DIR/pkg/a.py"$'\n'"$BATS_TMP_DIR/pkg/sub/b.py" ]]
}

@test "non-Python files are skipped silently" {
  local py="$BATS_TMP_DIR/dirty.py"
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'import os\n' > "$py"
  printf 'import os\n' > "$txt"

  bats_run_zsh "python-lint --json $py $txt"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$py" ]]
}

@test "extensionless file with a python shebang is linted" {
  local file="$BATS_TMP_DIR/script"
  printf '#!/usr/bin/env python3\nimport os\n' > "$file"

  bats_run_zsh "python-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "F401" ]]
}

@test "no Python file after filtering: no output, exits 0, ruff is not run" {
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$txt"

  ruff() { touch "$BATS_TMP_DIR/ruff_called"; }
  bats_mock ruff

  bats_run_zsh "python-lint $txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/ruff_called" ]]
}

@test "no Python file after filtering with --json: outputs [], exits 0" {
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$txt"

  bats_run_zsh "python-lint --json $txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

# --- JSON output (--json) ---

@test "--json: clean file outputs empty array, exits 0" {
  local file="$BATS_TMP_DIR/clean.py"
  printf 'x = 1\n' > "$file"

  bats_run_zsh "python-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--json: dirty file outputs unified JSON array with all fields" {
  local file="$BATS_TMP_DIR/dirty.py"
  printf 'import os\n' > "$file"

  bats_run_zsh "python-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "F401" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endLine')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "8" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endColumn')" == "10" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == *"imported but unused"* ]]
  # Unified schema has 8 fields only
  [[ "$(printf '%s' "$item" | jq 'keys | length')" == "8" ]]
}

@test "--json: every violation has level error" {
  local file="$BATS_TMP_DIR/dirty.py"
  printf 'import os\nimport sys\nx=1\n' > "$file"

  bats_run_zsh "python-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -ge 2 ]]
  [[ "$(printf '%s' "$output" | jq '[.[] | select(.level != "error")] | length')" == "0" ]]
}

# --- Internal errors ---

@test "ruff crashes: writes to stderr, nothing to stdout, exits 1" {
  local file="$BATS_TMP_DIR/dirty.py"
  printf 'import os\n' > "$file"

  ruff() {
    echo "ruff exploded" >&2
    return 2
  }
  bats_mock ruff

  bats_run_zsh "python-lint $file 2>&1 >/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"ruff exploded"* ]]

  bats_run_zsh "python-lint $file 2>/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "--json with ruff crash: no JSON on stdout, exits 1" {
  local file="$BATS_TMP_DIR/dirty.py"
  printf 'import os\n' > "$file"

  ruff() {
    echo "ruff exploded" >&2
    return 2
  }
  bats_mock ruff

  bats_run_zsh "python-lint --json $file 2>/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "no arguments: error on stderr, exits 1" {
  bats_run_zsh "python-lint 2>&1"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}
