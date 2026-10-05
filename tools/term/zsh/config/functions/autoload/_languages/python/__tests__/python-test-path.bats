bats_load_library 'helper'

setup() {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/src/__tests__"
}

@test "source file: prints the absolute path of its test file" {
  touch "$BATS_TMP_DIR/src/foo.py"
  touch "$BATS_TMP_DIR/src/__tests__/test_foo.py"

  bats_run_zsh "cd $BATS_TMP_DIR && python-test-path src/foo.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/src/__tests__/test_foo.py" ]]
}

@test "test file: returned as-is, absolute" {
  touch "$BATS_TMP_DIR/src/__tests__/test_foo.py"

  bats_run_zsh "cd $BATS_TMP_DIR && python-test-path src/__tests__/test_foo.py"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/src/__tests__/test_foo.py" ]]
}

@test "test file that does not exist: exits 1" {
  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/__tests__/test_missing.py"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "source file without test file: exits 1, empty output" {
  touch "$BATS_TMP_DIR/src/foo.py"

  bats_run_zsh "python-test-path $BATS_TMP_DIR/src/foo.py"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}

@test "no argument: exits 1" {
  bats_run_zsh "python-test-path"
  [[ "$status" -eq 1 ]]
}
