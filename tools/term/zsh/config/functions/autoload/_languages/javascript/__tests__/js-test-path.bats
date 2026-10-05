bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns test path for a .js source file with existing test" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/module.js"
  touch "$BATS_TMP_DIR/src/__tests__/module.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/module.js"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/src/__tests__/module.js" ]]
}

@test "returns the file directly when already a test" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/__tests__/module.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/__tests__/module.js"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/src/__tests__/module.js" ]]
}

@test "returns 1 when no matching test exists" {
  mkdir -p "$BATS_TMP_DIR/src"
  touch "$BATS_TMP_DIR/src/orphan.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/orphan.js"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns 1 with no arguments" {
  bats_run_zsh "js-test-path"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "returns 1 for non-JS file" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/style.css"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/style.css"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "maps each accepted extension to its __tests__ sibling" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  local ext
  for ext in jsx vue; do
    touch "$BATS_TMP_DIR/src/module.$ext"
    touch "$BATS_TMP_DIR/src/__tests__/module.$ext"
    bats_run_zsh "js-test-path $BATS_TMP_DIR/src/module.$ext"
    [[ "$status" -eq 0 ]]
    [[ "$output" = "$BATS_TMP_DIR/src/__tests__/module.$ext" ]]
  done
}

@test "returns a test file of each accepted extension unchanged" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  local ext
  for ext in jsx vue; do
    touch "$BATS_TMP_DIR/src/__tests__/module.$ext"
    bats_run_zsh "js-test-path $BATS_TMP_DIR/src/__tests__/module.$ext"
    [[ "$status" -eq 0 ]]
    [[ "$output" = "$BATS_TMP_DIR/src/__tests__/module.$ext" ]]
  done
}

@test "maps an extensionless node-shebang script to its __tests__ sibling" {
  mkdir -p "$BATS_TMP_DIR/bin/__tests__"
  printf '#!/usr/bin/env node\n' > "$BATS_TMP_DIR/bin/my-script"
  touch "$BATS_TMP_DIR/bin/__tests__/my-script"
  bats_run_zsh "js-test-path $BATS_TMP_DIR/bin/my-script"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/bin/__tests__/my-script" ]]
}

@test "returns 1 for .ts and .tsx files even with a sibling test" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  local ext
  for ext in ts tsx; do
    touch "$BATS_TMP_DIR/src/module.$ext"
    touch "$BATS_TMP_DIR/src/__tests__/module.$ext"
    bats_run_zsh "js-test-path $BATS_TMP_DIR/src/module.$ext"
    [[ "$status" -eq 1 ]]
    [[ "$output" = "" ]]
  done
}

@test "returns 1 for a .ts or .tsx file inside __tests__" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  local ext
  for ext in ts tsx; do
    touch "$BATS_TMP_DIR/src/__tests__/module.$ext"
    bats_run_zsh "js-test-path $BATS_TMP_DIR/src/__tests__/module.$ext"
    [[ "$status" -eq 1 ]]
    [[ "$output" = "" ]]
  done
}

@test "returns 1 when no test exists for a .vue source or a node-shebang script" {
  mkdir -p "$BATS_TMP_DIR/src"
  touch "$BATS_TMP_DIR/src/orphan.vue"
  printf '#!/usr/bin/env node\n' > "$BATS_TMP_DIR/src/orphan-script"
  local file
  for file in orphan.vue orphan-script; do
    bats_run_zsh "js-test-path $BATS_TMP_DIR/src/$file"
    [[ "$status" -eq 1 ]]
    [[ "$output" = "" ]]
  done
}
