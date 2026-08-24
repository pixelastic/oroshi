bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
}

mock_eslint() {
  yarn-root() { echo ""; }
  cat > "$BATS_TMP_DIR/mock-eslint_d"
  chmod +x "$BATS_TMP_DIR/mock-eslint_d"
  eslint_d() { "$BATS_TMP_DIR/mock-eslint_d" "$@"; }
  bats_mock yarn-root eslint_d
  bats_disable_worktree_aware
}

@test "outputs stylish violations for a file with lint errors" {
  local file="$BATS_TMP_DIR/bad.js"
  printf 'var x = 1;\n' > "$file"

  mock_eslint <<'SCRIPT'
#!/bin/bash
printf 'bad.js\n  3:5  error  Unexpected var  no-var\n\n1 problem\n'
exit 1
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"no-var"* ]]
}

@test "outputs nothing for a clean file (exit 0)" {
  local file="$BATS_TMP_DIR/clean.js"
  printf 'const x = 1;\n' > "$file"

  mock_eslint <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "--json outputs unified schema array for a file with lint errors" {
  local file="$BATS_TMP_DIR/bad.js"
  printf 'var x = 1;\n' > "$file"

  mock_eslint <<SCRIPT
#!/bin/bash
printf '[{"filePath":"$file","messages":[{"ruleId":"no-unused-vars","severity":2,"message":"x is defined but never used","line":3,"column":5},{"ruleId":"no-console","severity":1,"message":"Unexpected console","line":5,"column":1}],"errorCount":1,"warningCount":1}]\n'
exit 1
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint --json $file"
  [[ "$status" -eq 1 ]]
  # Severity 2 → error
  local item0="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item0" | jq -r '.file')" == "$file" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.code')" == "no-unused-vars" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.level')" == "error" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.line')" == "3" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.column')" == "5" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.message')" == "x is defined but never used" ]]
  [[ "$(printf '%s' "$item0" | jq 'keys | length')" == "6" ]]
  # Severity 1 → warn
  [[ "$(printf '%s' "$output" | jq -r '.[1].level')" == "warn" ]]
}

@test "--json outputs [] for a clean file (exit 0)" {
  local file="$BATS_TMP_DIR/clean.js"
  printf 'const x = 1;\n' > "$file"

  mock_eslint <<SCRIPT
#!/bin/bash
printf '[{"filePath":"$file","messages":[],"errorCount":0,"warningCount":0}]\n'
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint --json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "lints multiple files in one call" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf 'var x;\n' > "$file1"
  printf 'var y;\n' > "$file2"

  mock_eslint <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/eslint_args"
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file1 $file2"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/eslint_args")"
  [[ "$args" == *"$file1"* ]]
  [[ "$args" == *"$file2"* ]]
}

@test "exits 1 when violations found" {
  local file="$BATS_TMP_DIR/bad.js"
  printf 'var x;\n' > "$file"

  mock_eslint <<'SCRIPT'
#!/bin/bash
echo "violation found"
exit 1
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 1 ]]
}
