bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export LIB_DIR="${BATS_TEST_DIRNAME}/.."
}

mock_prettier() {
  yarn-root() { echo ""; }
  cat > "$BATS_TMP_DIR/mock-prettier"
  chmod +x "$BATS_TMP_DIR/mock-prettier"
  prettier() { "$BATS_TMP_DIR/mock-prettier" "$@"; }
  bats_mock yarn-root prettier
  bats_disable_worktree_aware
}

@test "modifies file in-place (formatting applied after run)" {
  local file="$BATS_TMP_DIR/ugly.json"
  printf '{"a":1}\n' > "$file"

  mock_prettier <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/prettier_args"
printf '{\n  "a": 1\n}\n' > "$file"
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/prettier_args")"
  [[ "$args" == *"--write"* ]]
}

@test "--parser json formats a JSON file" {
  local file="$BATS_TMP_DIR/test.json"
  printf '{"a":1}\n' > "$file"

  mock_prettier <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/prettier_args"
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/prettier_args")"
  [[ "$args" == *"--parser"* ]]
  [[ "$args" == *"json"* ]]
}

@test "--original-path resolves config from the given path" {
  local file="$BATS_TMP_DIR/tmp-copy.json"
  local originalPath="/home/user/project/config.json"
  printf '{"a":1}\n' > "$file"

  cat > "$BATS_TMP_DIR/mock-prettier" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
  chmod +x "$BATS_TMP_DIR/mock-prettier"

  yarn-root() {
    printf '%s\n' "$*" >> "$BATS_TMP_DIR/yarn_root_args"
    echo ""
  }
  prettier() { "$BATS_TMP_DIR/mock-prettier" "$@"; }
  bats_mock yarn-root prettier
  bats_disable_worktree_aware

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file --original-path $originalPath"
  [[ "$status" -eq 0 ]]
  local yarnArgs="$(cat "$BATS_TMP_DIR/yarn_root_args")"
  [[ "$yarnArgs" == *"/home/user/project"* ]]
}

@test "--original-path with multiple files exits 1" {
  local file1="$BATS_TMP_DIR/a.json"
  local file2="$BATS_TMP_DIR/b.json"
  printf '' > "$file1"
  printf '' > "$file2"

  mock_prettier <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file1 $file2 --original-path /some/path"
  [[ "$status" -eq 1 ]]
}

@test "does not produce stdout output" {
  local file="$BATS_TMP_DIR/test.json"
  printf '{"a":1}\n' > "$file"

  mock_prettier <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "runs the global prettier with the oroshi config when the project has a local binary but no config" {
  local projectDir="$BATS_TMP_DIR/project"
  local file="$projectDir/test.json"
  mkdir -p "$projectDir/node_modules/.bin"
  printf '{"a":1}\n' > "$file"

  # Local prettier leaves a marker file if it runs
  cat > "$projectDir/node_modules/.bin/prettier" <<SCRIPT
#!/bin/bash
touch "$BATS_TMP_DIR/local_prettier_called"
exit 0
SCRIPT
  chmod +x "$projectDir/node_modules/.bin/prettier"

  mock_prettier <<SCRIPT
#!/bin/bash
printf '%s\n' "\$*" > "$BATS_TMP_DIR/prettier_args"
exit 0
SCRIPT
  # Override mock_prettier's yarn-root so the file belongs to the project
  yarn-root() { echo "$PROJECT_DIR"; }
  bats_mock yarn-root
  bats_mock_env PROJECT_DIR "$projectDir"

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/local_prettier_called" ]]
  local args="$(cat "$BATS_TMP_DIR/prettier_args")"
  [[ "$args" == *"--config $OROSHI_ROOT/prettier.config.js"* ]]
}

@test "prints prettier stderr when prettier fails" {
  local file="$BATS_TMP_DIR/test.xml"
  printf '<a/>\n' > "$file"

  mock_prettier <<'SCRIPT'
#!/bin/bash
echo "Cannot find package '@prettier/plugin-xml'" >&2
exit 2
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser xml $file"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Cannot find package '@prettier/plugin-xml'"* ]]
}

@test "prints nothing on stdout when prettier succeeds" {
  local file="$BATS_TMP_DIR/test.json"
  printf '{"a":1}\n' > "$file"

  mock_prettier <<'SCRIPT'
#!/bin/bash
echo "test.json 12ms"
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix --parser json $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "errors when --parser not provided" {
  local file="$BATS_TMP_DIR/test.json"
  printf '{"a":1}\n' > "$file"

  mock_prettier <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT

  bats_run_zsh "source $LIB_DIR/prettier-fix.zsh && prettier-fix $file"
  [[ "$status" -ne 0 ]]
}
