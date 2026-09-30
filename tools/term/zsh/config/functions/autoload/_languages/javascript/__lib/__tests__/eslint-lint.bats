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
printf '[{"filePath":"$file","messages":[{"ruleId":"no-unused-vars","severity":2,"message":"x is defined but never used","line":3,"column":5,"endLine":3,"endColumn":6},{"ruleId":"no-console","severity":1,"message":"Unexpected console","line":5,"column":1,"endLine":5,"endColumn":12}],"errorCount":1,"warningCount":1}]\n'
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
  [[ "$(printf '%s' "$item0" | jq -r '.endLine')" == "3" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.endColumn')" == "6" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.message')" == "x is defined but never used" ]]
  [[ "$(printf '%s' "$item0" | jq 'keys | length')" == "8" ]]
  # Severity 1 → warn
  [[ "$(printf '%s' "$output" | jq -r '.[1].level')" == "warn" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1].endLine')" == "5" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1].endColumn')" == "12" ]]
}

@test "--json falls back endLine/endColumn to line/column when missing" {
  local file="$BATS_TMP_DIR/bad.js"
  printf 'var x = 1;\n' > "$file"

  mock_eslint <<SCRIPT
#!/bin/bash
printf '[{"filePath":"$file","messages":[{"ruleId":"no-var","severity":2,"message":"Use const","line":1,"column":1}],"errorCount":1,"warningCount":0}]\n'
exit 1
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint --json $file"
  [[ "$status" -eq 1 ]]
  local item0="$(printf '%s' "$output" | jq '.[0]')"
  [[ "$(printf '%s' "$item0" | jq -r '.endLine')" == "1" ]]
  [[ "$(printf '%s' "$item0" | jq -r '.endColumn')" == "1" ]]
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

# Binary and config pairing

mock_global_eslint() {
  # Global eslint_d records its name, root and arguments
  mock_eslint <<SCRIPT
#!/bin/bash
printf 'global %s\n' "\$*" > "$BATS_TMP_DIR/eslint_call"
printf '%s\n' "\$ESLINT_D_ROOT" > "$BATS_TMP_DIR/eslint_root"
exit 0
SCRIPT
}

mock_eslint_in_project() {
  local projectDirectory="$1"
  mkdir -p "$projectDirectory"
  mock_global_eslint

  # Override mock_eslint's yarn-root so the file belongs to the project
  yarn-root() { echo "$PROJECT_DIR"; }
  bats_mock yarn-root
  bats_mock_env PROJECT_DIR "$projectDirectory"
}

add_local_eslint() {
  local projectDirectory="$1"
  mkdir -p "$projectDirectory/node_modules/.bin"

  # Local eslint_d records its name, root and arguments
  cat > "$projectDirectory/node_modules/.bin/eslint_d" <<SCRIPT
#!/bin/bash
printf 'local %s\n' "\$*" > "$BATS_TMP_DIR/eslint_call"
printf '%s\n' "\$ESLINT_D_ROOT" > "$BATS_TMP_DIR/eslint_root"
exit 0
SCRIPT
  chmod +x "$projectDirectory/node_modules/.bin/eslint_d"
}

@test "runs the global eslint_d with the oroshi config when the project has a local eslint_d but no config" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project "$projectDirectory"
  add_local_eslint "$projectDirectory"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_call")" == "global --config $OROSHI_ROOT/eslint.config.js "* ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$OROSHI_ROOT" ]]
}

@test "runs the local eslint_d with the project config when the project has both" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project "$projectDirectory"
  add_local_eslint "$projectDirectory"
  touch "$projectDirectory/eslint.config.js"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_call")" == "local --config $projectDirectory/eslint.config.js "* ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$projectDirectory" ]]
}

@test "runs the global eslint_d with the project config when the project has a config but no local eslint_d" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project "$projectDirectory"
  touch "$projectDirectory/eslint.config.js"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_call")" == "global --config $projectDirectory/eslint.config.js "* ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$projectDirectory" ]]
}

@test "runs the global eslint_d with the oroshi config when there is no project" {
  local file="$BATS_TMP_DIR/app.js"
  printf 'const x = 1;\n' > "$file"
  mock_global_eslint

  bats_run_zsh "source $LIB_DIR/eslint-lint.zsh && eslint-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_call")" == "global --config $OROSHI_ROOT/eslint.config.js "* ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$OROSHI_ROOT" ]]
}
