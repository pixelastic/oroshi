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

@test "modifies file in-place (fixable issue resolved after run)" {
  local file="$BATS_TMP_DIR/fixable.js"
  printf 'var x = 1;\n' > "$file"

  mock_eslint <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/eslint_args"
# Simulate in-place fix
printf 'const x = 1;\n' > "$file"
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/eslint_args")"
  [[ "$args" == *"--fix"* ]]
  [[ "$(cat "$file")" == "const x = 1;" ]]
}

@test "--original-path resolves config from the given path" {
  local file="$BATS_TMP_DIR/tmp-copy.js"
  local originalDir="$BATS_TMP_DIR/project/src"
  mkdir -p "$originalDir"
  local originalPath="$originalDir/app.js"
  printf 'var x;\n' > "$file"

  cat > "$BATS_TMP_DIR/mock-eslint_d" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
  chmod +x "$BATS_TMP_DIR/mock-eslint_d"

  yarn-root() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/yarn_root_args"
    echo ""
  }
  eslint_d() { "$BATS_TMP_DIR/mock-eslint_d" "$@"; }
  bats_mock yarn-root eslint_d
  bats_disable_worktree_aware

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file --original-path $originalPath"
  [[ "$status" -eq 0 ]]
  local yarnArgs="$(cat "$BATS_TMP_DIR/yarn_root_args")"
  [[ "$yarnArgs" == *"$originalDir"* ]]
}

@test "--original-path with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.js"
  local file2="$BATS_TMP_DIR/b.js"
  printf '' > "$file1"
  printf '' > "$file2"

  mock_eslint <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file1 $file2 --original-path /some/path"
  [[ "$status" -eq 1 ]]
}

# Binary and config pairing

mock_global_eslint_fix() {
  mock_eslint <<SCRIPT
#!/bin/bash
printf 'global %s\n' "\$*" > "$BATS_TMP_DIR/eslint_call"
printf '%s\n' "\$ESLINT_D_ROOT" > "$BATS_TMP_DIR/eslint_root"
exit 0
SCRIPT
}

mock_eslint_in_project_fix() {
  local projectDirectory="$1"
  mkdir -p "$projectDirectory"
  mock_global_eslint_fix

  yarn-root() { echo "$PROJECT_DIR"; }
  bats_mock yarn-root
  bats_mock_env PROJECT_DIR "$projectDirectory"
}

add_local_eslint_fix() {
  local projectDirectory="$1"
  mkdir -p "$projectDirectory/node_modules/.bin"

  cat > "$projectDirectory/node_modules/.bin/eslint_d" <<SCRIPT
#!/bin/bash
printf 'local %s\n' "\$*" > "$BATS_TMP_DIR/eslint_call"
printf '%s\n' "\$ESLINT_D_ROOT" > "$BATS_TMP_DIR/eslint_root"
exit 0
SCRIPT
  chmod +x "$projectDirectory/node_modules/.bin/eslint_d"
}

@test "fix: uses oroshi root when project has a local eslint_d but no config" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project_fix "$projectDirectory"
  add_local_eslint_fix "$projectDirectory"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$OROSHI_ROOT" ]]
}

@test "fix: uses project root when project has both config and local eslint_d" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project_fix "$projectDirectory"
  add_local_eslint_fix "$projectDirectory"
  touch "$projectDirectory/eslint.config.js"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$projectDirectory" ]]
}

@test "fix: uses project root when project has a config but no local eslint_d" {
  local projectDirectory="$BATS_TMP_DIR/project"
  local file="$projectDirectory/app.js"
  mock_eslint_in_project_fix "$projectDirectory"
  touch "$projectDirectory/eslint.config.js"
  printf 'const x = 1;\n' > "$file"

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$projectDirectory" ]]
}

@test "fix: uses oroshi root when there is no project" {
  local file="$BATS_TMP_DIR/app.js"
  printf 'const x = 1;\n' > "$file"
  mock_global_eslint_fix

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$(< "$BATS_TMP_DIR/eslint_root")" == "$OROSHI_ROOT" ]]
}

@test "does not produce stdout output" {
  local file="$BATS_TMP_DIR/clean.js"
  printf 'const x = 1;\n' > "$file"

  mock_eslint <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/eslint-fix.zsh && eslint-fix $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
