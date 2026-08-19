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

@test "clean file: outputs empty array, exits 0" {
  local file="$BATS_TMP_DIR/clean.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[],"Report":{}}\n'
exit 0
SCRIPT

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "dirty file: outputs unified JSON array with all fields" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"var x is unused","Severity":"","Pos":{"Filename":"dirty.go","Line":3,"Column":5},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 1 ]]
  local item="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item" | jq -r '.file')" == "dirty.go" ]]
  [[ "$(printf '%s' "$item" | jq -r '.code')" == "unused" ]]
  [[ "$(printf '%s' "$item" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item" | jq -r '.line')" == "3" ]]
  [[ "$(printf '%s' "$item" | jq -r '.column')" == "5" ]]
  [[ "$(printf '%s' "$item" | jq -r '.message')" == "var x is unused" ]]
  # endLine/endColumn fall back to line/column when End is zero
  [[ "$(printf '%s' "$item" | jq -r '.endLine')" == "3" ]]
  [[ "$(printf '%s' "$item" | jq -r '.endColumn')" == "5" ]]
}

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

@test "--fix with remaining violations: exits 1" {
  local file="$BATS_TMP_DIR/dirty.go"
  printf 'package main\n' > "$file"

  mock_linter <<'SCRIPT'
#!/bin/bash
# Fix pass succeeds, report pass finds remaining violations
for arg in "$@"; do
  [[ "$arg" == "--fix" ]] && { printf '{"Issues":[]}\n'; exit 0; }
done
printf '{"Issues":[{"FromLinter":"ineffassign","Text":"ineffective assign","Severity":"","Pos":{"Filename":"dirty.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint --fix $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"ineffassign"* ]]
}

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

  bats_run_zsh "go-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0].file')" == "main.go" ]]
}

@test "directory input: shows all violations without filtering" {
  printf 'package main\n' > "$BATS_TMP_DIR/main.go"

  mock_linter <<'SCRIPT'
#!/bin/bash
printf '{"Issues":[{"FromLinter":"unused","Text":"in main","Severity":"","Pos":{"Filename":"main.go","Line":3,"Column":1},"End":{"Filename":"","Line":0,"Column":0}},{"FromLinter":"unused","Text":"in other","Severity":"","Pos":{"Filename":"other.go","Line":5,"Column":1},"End":{"Filename":"","Line":0,"Column":0}}],"Report":{}}\n'
exit 1
SCRIPT

  bats_run_zsh "go-lint $BATS_TMP_DIR"
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
