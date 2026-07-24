bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "already a test file: returned as-is" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/__tests__/test_foo.py"

  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/__tests__/test_foo.py"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/src/__tests__/test_foo.py" ]
}

@test "already a test file but missing: exits non-zero" {
  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/__tests__/test_missing.py"
  [ "$status" -eq 1 ]
}

@test "source file with matching test: returns test path" {
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
  touch "$BATS_TMP_DIR/src/foo.py"
  touch "$BATS_TMP_DIR/src/__tests__/test_foo.py"

  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/foo.py"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMP_DIR/src/__tests__/test_foo.py" ]
}

@test "no matching test: exits non-zero, empty output" {
  mkdir -p "$BATS_TMP_DIR/src"
  touch "$BATS_TMP_DIR/src/foo.py"

  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/foo.py"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "no argument: exits non-zero" {
  bats_run_zsh "python-test-path"
  [ "$status" -eq 1 ]
}
