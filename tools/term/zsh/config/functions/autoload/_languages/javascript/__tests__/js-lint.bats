bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/clean.js"
  printf 'export const a = 1;\n' > "$file"

  bats_run_zsh "js-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "dirty file: outputs stylish format and exits 1" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'export const a = undefinedName;\n' > "$file"

  bats_run_zsh "js-lint $file"
  [[ "$status" -eq 1 ]]
  # File header line
  [[ "$output" == *"$file"* ]]
  # Violation line: line:column  level  message  code
  [[ "$output" == *"1:18  error  "* ]]
  [[ "$output" == *"no-undef"* ]]
}

@test "multiple files: violations grouped by file, separated by a blank line" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf 'export const a = undefinedName;\n' > "$file1"
  printf 'export const b = undefinedName;\n' > "$file2"

  bats_run_zsh "js-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"$file1"* ]]
  [[ "$output" == *"$file2"* ]]
  [[ "$output" == *$'\n\n'* ]]
}

@test "clean file next to a dirty file: only the dirty file is reported" {
  local file1="$BATS_TMP_DIR/clean.js"
  local file2="$BATS_TMP_DIR/dirty.js"
  printf 'export const a = 1;\n' > "$file1"
  printf 'export const b = undefinedName;\n' > "$file2"

  bats_run_zsh "js-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  [[ "$output" != *"clean.js"* ]]
  [[ "$output" == *"dirty.js"* ]]
}

@test "relative path: file is linted from another working directory" {
  printf 'export const a = undefinedName;\n' > "$BATS_TMP_DIR/dirty.js"

  bats_run_zsh "cd $BATS_TMP_DIR && js-lint --json dirty.js"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$BATS_TMP_DIR/dirty.js" ]]
}

# --- File expansion ---

@test "directory input: lints the JS files below it" {
  mkdir -p "$BATS_TMP_DIR/pkg/sub"
  printf 'export const a = undefinedName;\n' > "$BATS_TMP_DIR/pkg/a.js"
  printf 'export const b = undefinedName;\n' > "$BATS_TMP_DIR/pkg/sub/b.js"

  bats_run_zsh "js-lint --json $BATS_TMP_DIR/pkg"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[].file' | sort -u)" == "$BATS_TMP_DIR/pkg/a.js"$'\n'"$BATS_TMP_DIR/pkg/sub/b.js" ]]
}

@test "non-JS files are skipped silently" {
  local js="$BATS_TMP_DIR/dirty.js"
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'export const a = undefinedName;\n' > "$js"
  printf 'var a = 1;\n' > "$txt"

  bats_run_zsh "js-lint --json $js $txt"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[].file' | sort -u)" == "$js" ]]
}

@test "no JS file after filtering: no output, exits 0, eslint is not run" {
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$txt"

  eslint_d() { touch "$BATS_TMP_DIR/eslint_called"; }
  bats_mock eslint_d

  bats_run_zsh "js-lint $txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/eslint_called" ]]
}

@test "no JS file after filtering with --json: outputs [], exits 0" {
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$txt"

  bats_run_zsh "js-lint --json $txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

# --- JSON output (--json) ---

@test "--json: clean file outputs empty array, exits 0" {
  local file="$BATS_TMP_DIR/clean.js"
  printf 'export const a = 1;\n' > "$file"

  bats_run_zsh "js-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--json: dirty file outputs unified JSON array with all fields" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'export const a = undefinedName;\n' > "$file"

  bats_run_zsh "js-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "no-undef" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "1" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "18" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == *"undefinedName"* ]]
  # Unified schema has 8 fields only
  [[ "$(printf '%s' "$item" | jq 'keys | length')" == "8" ]]
}

@test "--json: maps eslint severities and falls back to line/column for the end" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'export const a = 1;\n' > "$file"

  eslint_d() {
    printf '[{"filePath":"%s","messages":[{"ruleId":"no-var","severity":2,"message":"boom","line":3,"column":5,"endLine":3,"endColumn":9},{"ruleId":"no-console","severity":1,"message":"careful","line":7,"column":2}]}]\n' "$BATS_TMP_DIR/dirty.js"
    return 1
  }
  bats_mock eslint_d

  bats_run_zsh "js-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].level')" == "error" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1].level')" == "warn" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].endColumn')" == "9" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1].endLine')" == "7" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1].endColumn')" == "2" ]]
}

@test "--json: omits code when eslint reports none (parse error)" {
  local file="$BATS_TMP_DIR/broken.js"
  printf 'const = ;\n' > "$file"

  bats_run_zsh "js-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq '.[0] | has("code")')" == "false" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].level')" == "error" ]]
}

# --- Internal errors ---

@test "eslint crashes: writes to stderr, nothing to stdout, exits 1" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'var a = 1;\n' > "$file"

  eslint_d() {
    echo "eslint exploded" >&2
    return 2
  }
  bats_mock eslint_d

  bats_run_zsh "js-lint $file 2>&1 >/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"eslint exploded"* ]]

  bats_run_zsh "js-lint $file 2>/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "--json with eslint crash: no JSON on stdout, exits 1" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'var a = 1;\n' > "$file"

  eslint_d() {
    echo "eslint exploded" >&2
    return 2
  }
  bats_mock eslint_d

  bats_run_zsh "js-lint --json $file 2>/dev/null"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "no arguments: error on stderr, exits 1" {
  bats_run_zsh "js-lint 2>&1"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No files provided"* ]]
}

# --- Fix mode (--fix) ---

@test "--fix: formats the file and prints nothing when no violation remains" {
  local file="$BATS_TMP_DIR/messy.js"
  printf 'const   a   =   {b:1}\nexport {a}\n' > "$file"

  bats_run_zsh "js-lint --fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ "$(cat "$file")" == $'const a = { b: 1 };\nexport { a };' ]]
}

@test "--fix: fixes what can be fixed, then reports what remains in stylish format" {
  local file="$BATS_TMP_DIR/remaining.js"
  printf 'const   a   =   1\nexport {a}\nexport const b = undefinedName\n' > "$file"

  bats_run_zsh "js-lint --fix $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"$file"* ]]
  [[ "$output" == *"no-undef"* ]]
  [[ "$output" != *"prettier/prettier"* ]]
  [[ "$(cat "$file")" == *"const a = 1;"* ]]
}

@test "--fix --json: reports remaining violations as unified JSON" {
  local file="$BATS_TMP_DIR/remaining.js"
  printf 'var a = 1\nexport { a }\nexport const b = undefinedName\n' > "$file"

  bats_run_zsh "js-lint --fix --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '[.[].code] | unique | join(",")')" == "no-undef" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$file" ]]
}

@test "--fix --json: outputs [] and exits 0 when no violation remains" {
  local file="$BATS_TMP_DIR/messy.js"
  printf 'const   a   =   {b:1}\nexport {a}\n' > "$file"

  bats_run_zsh "js-lint --fix --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--fix: does not lint and exits 1 when the fix step fails" {
  local file="$BATS_TMP_DIR/dirty.js"
  printf 'var a = 1;\n' > "$file"

  js-fix() { return 1; }
  eslint_d() { touch "$BATS_TMP_DIR/eslint_called"; }
  bats_mock js-fix eslint_d

  bats_run_zsh "js-lint --fix $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/eslint_called" ]]
}

@test "--fix: no JS file after filtering, js-fix is not run" {
  local txt="$BATS_TMP_DIR/notes.txt"
  printf 'hello\n' > "$txt"

  js-fix() { touch "$BATS_TMP_DIR/fix_called"; }
  bats_mock js-fix

  bats_run_zsh "js-lint --fix $txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/fix_called" ]]
}
