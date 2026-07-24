bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns test path for a .js source file with existing test" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/module.js"
  touch "$BATS_TMP_DIR/src/__tests__/module.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/module.js"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/src/__tests__/module.js" ]
}

@test "returns the file directly when already a test" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/__tests__/module.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/__tests__/module.js"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/src/__tests__/module.js" ]
}

@test "returns 1 when no matching test exists" {
  mkdir -p "$BATS_TMP_DIR/src"
  touch "$BATS_TMP_DIR/src/orphan.js"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/orphan.js"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "returns 1 with no arguments" {
  bats_run_zsh "js-test-path"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "returns 1 for non-JS file" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/style.css"

  bats_run_zsh "js-test-path $BATS_TMP_DIR/src/style.css"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}
