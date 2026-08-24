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
