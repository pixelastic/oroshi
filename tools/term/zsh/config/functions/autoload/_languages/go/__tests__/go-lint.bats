bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf 'module test\n\ngo 1.25\n' > "$BATS_TMP_DIR/go.mod"
}

# Create a mock golangci-lint binary with custom behavior
mock_linter() {
  cat > "$BATS_TMP_DIR/mock-lint"
  chmod +x "$BATS_TMP_DIR/mock-lint"
  go-tool-path() { echo "$BATS_TMP_DIR/mock-lint"; }
  go-module-root() { echo "$BATS_TMP_DIR"; }
  bats_mock go-tool-path go-module-root
  bats_disable_worktree_aware
}

# --- Stylish output (default) ---

@test "clean file: no output, exits 0" {
  local file="$BATS_TMP_DIR/clean.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "dirty file: outputs stylish format with violations grouped by file" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"var x is unused","Severity":"","Pos":{"Filename":"dirty.go","Line":3,"Column":5},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 1 ]]
  # File header line
  [[ "$output" == *"dirty.go"* ]]
  # Violation line: line:col  level  message  code
  [[ "$output" == *"3:5"* ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"var x is unused"* ]]
  [[ "$output" == *"unused"* ]]
}

@test "multiple files: violations grouped by file, separated by blank lines" {
  local file1="$BATS_TMP_DIR/a.go"
  local file2="$BATS_TMP_DIR/b.go"
  printf 'package main\n' > "$file1"
  printf 'package main\n' > "$file2"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"unused a","Severity":"","Pos":{"Filename":"a.go","Line":1,"Column":1},"End":{"Filename":"","Line":0,"Column":0}},{"FromLinter":"unused","Text":"unused b","Severity":"","Pos":{"Filename":"b.go","Line":2,"Column":3},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint $file1 $file2"
  [[ "$status" -eq 1 ]]
  # Both files appear as headers
  [[ "$output" == *"a.go"* ]]
  [[ "$output" == *"b.go"* ]]
  # Blank line separates file groups (header + violation + blank + header + violation)
  local lineCount="$(printf '%s\n' "$output" | wc -l)"
  [[ "$lineCount" -ge 5 ]]
}

@test "stylish output: columns are aligned and warning maps to warn" {
  local file="$BATS_TMP_DIR/test.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"SC2086","Text":"Missing double quotes","Severity":"","Pos":{"Filename":"test.go","Line":3,"Column":10},"End":{"Filename":"","Line":0,"Column":0}},{"FromLinter":"SC2154","Text":"Variable not assigned","Severity":"warning","Pos":{"Filename":"test.go","Line":7,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 1 ]]
  # warning severity maps to warn
  [[ "$output" == *"warn"* ]]
  # Level column starts at the same byte offset in both violation lines
  local line1="$(printf '%s\n' "$output" | grep 'error')"
  local line2="$(printf '%s\n' "$output" | grep 'warn')"
  local pos1="$(printf '%s' "$line1" | grep -bo 'error' | head -1 | cut -d: -f1)"
  local pos2="$(printf '%s' "$line2" | grep -bo 'warn' | head -1 | cut -d: -f1)"
  [[ "$pos1" -eq "$pos2" ]]
}

@test "rule ID prefix extracted from message into code field" {
  local file="$BATS_TMP_DIR/test.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"staticcheck","Text":"S1021: should merge variable declaration","Severity":"","Pos":{"Filename":"test.go","Line":5,"Column":2},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --json $file"
  [[ "$status" -eq 1 ]]
  # Code is the extracted rule ID, not the linter name
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "S1021" ]]
  # Message has the prefix stripped
  [[ "$(printf '%s' "$output" | jq -r '.[0].message')" == "should merge variable declaration" ]]
}

# --- JSON output (--json) ---

@test "--json: clean file outputs empty array, exits 0" {
  local file="$BATS_TMP_DIR/clean.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "--json: dirty file outputs unified JSON array with all fields" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"var x is unused","Severity":"","Pos":{"Filename":"dirty.go","Line":3,"Column":5},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  # file is absolute path (module root + relative)
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "$BATS_TMP_DIR/dirty.go" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "unused" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "3" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "5" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == "var x is unused" ]]
  # No endLine/endColumn — unified schema has 6 fields only
  [[ "$(printf '%s' "$item" | jq 'keys | length')" == "6" ]]
}

# --- Directory expansion ---

@test "directory input: expands via file-expand --filter is-go" {
  mkdir -p "$BATS_TMP_DIR/mydir"
  printf 'package main\n' > "$BATS_TMP_DIR/mydir/main.go"

  file-expand() {
    printf '%s\n' "$@" > "$BATS_TMP_DIR/expand_args"
    printf '%s\n' "$BATS_TMP_DIR/mydir/main.go"
  }
  bats_mock file-expand

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint $BATS_TMP_DIR/mydir/"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/expand_args")"
  [[ "$args" == *"--filter"* ]]
  [[ "$args" == *"is-go"* ]]
}

# --- Fix mode ---

@test "--fix: runs fix pass then report pass" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" >> "$BATS_TMP_DIR/lint_calls"
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint --fix $file"
  [[ "$status" -eq 0 ]]
  local calls="$(cat "$BATS_TMP_DIR/lint_calls")"
  # First call has --fix, second has --out-format json
  [[ "$calls" == *"--fix"* ]]
  [[ "$calls" == *"--output.json.path"* ]]
  [[ "$(wc -l < "$BATS_TMP_DIR/lint_calls")" -eq 2 ]]
}

@test "--fix with remaining violations: stylish output, exits 1" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
for arg in "$@"; do
  [[ "$arg" == "--fix" ]] && { printf '{"Issues":[]}\n'; exit 0; }
done
printf '{"Issues":[{"FromLinter":"ineffassign","Text":"ineffective assign","Severity":"","Pos":{"Filename":"dirty.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --fix $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"dirty.go"* ]]
  [[ "$output" == *"5:1"* ]]
  [[ "$output" == *"ineffassign"* ]]
}

@test "--fix --json: remaining violations as JSON" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
for arg in "$@"; do
  [[ "$arg" == "--fix" ]] && { printf '{"Issues":[]}\n'; exit 0; }
done
printf '{"Issues":[{"FromLinter":"ineffassign","Text":"ineffective assign","Severity":"","Pos":{"Filename":"dirty.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --fix --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].code')" == "ineffassign" ]]
}

# --- Existing behavior preserved ---

@test "multiple files in same dir: deduplicates package" {
  local file1="$BATS_TMP_DIR/a.go"
  local file2="$BATS_TMP_DIR/b.go"
  printf 'package main\n' > "$file1"
  printf 'package main\n' > "$file2"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint $file1 $file2"
  [[ "$status" -eq 0 ]]
}

@test "file input: filters out violations from other files in same package" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"
  printf 'package main\n' > "$BATS_TMP_DIR/other.go"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"in main","Severity":"","Pos":{"Filename":"main.go","Line":3,"Column":1},"End":{"Filename":"","Line":0,"Column":0}},{"FromLinter":"unused","Text":"in other","Severity":"","Pos":{"Filename":"other.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --json $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "$BATS_TMP_DIR/main.go" ]]
}

@test "directory input: shows violations from all expanded files" {
  printf 'package main\n' > "$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$BATS_TMP_DIR/other.go"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"in main","Severity":"","Pos":{"Filename":"main.go","Line":3,"Column":1},"End":{"Filename":"","Line":0,"Column":0}},{"FromLinter":"unused","Text":"in other","Severity":"","Pos":{"Filename":"other.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --json $BATS_TMP_DIR"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "2" ]]
}

@test "multiple files in different dirs: passes both package dirs" {
  mkdir -p "$BATS_TMP_DIR/pkg1" "$BATS_TMP_DIR/pkg2"
  local file1="$BATS_TMP_DIR/pkg1/a.go"
  local file2="$BATS_TMP_DIR/pkg2/b.go"
  printf 'package pkg1\n' > "$file1"
  printf 'package pkg2\n' > "$file2"

  mock_linter <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/lint_args"
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint $file1 $file2"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/lint_args")"
  [[ "$args" == *"pkg1"* ]]
  [[ "$args" == *"pkg2"* ]]
}
