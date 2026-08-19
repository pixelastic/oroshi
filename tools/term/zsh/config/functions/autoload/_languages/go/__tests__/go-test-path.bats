bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns foo_test.go when given foo.go and test file exists" {
  echo "package main" > "$BATS_TMP_DIR/foo.go"
  echo "package main" > "$BATS_TMP_DIR/foo_test.go"
  bats_run_zsh "go-test-path $BATS_TMP_DIR/foo.go"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/foo_test.go" ]]
}

@test "returns the test file directly when given foo_test.go" {
  echo "package main" > "$BATS_TMP_DIR/foo_test.go"
  bats_run_zsh "go-test-path $BATS_TMP_DIR/foo_test.go"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/foo_test.go" ]]
}

@test "exits 1 with empty output when no test file exists" {
  echo "package main" > "$BATS_TMP_DIR/foo.go"
  bats_run_zsh "go-test-path $BATS_TMP_DIR/foo.go"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "" ]]
}
