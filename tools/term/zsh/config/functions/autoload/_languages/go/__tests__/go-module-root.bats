bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns directory containing go.mod when given a file" {
  printf 'module test\n' > "$BATS_TMP_DIR/go.mod"
  printf 'package main\n' > "$BATS_TMP_DIR/main.go"

  bats_run_zsh "go-module-root $BATS_TMP_DIR/main.go"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR" ]]
}

@test "returns directory containing go.mod when given a directory" {
  printf 'module test\n' > "$BATS_TMP_DIR/go.mod"

  bats_run_zsh "go-module-root $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR" ]]
}

@test "walks up to find go.mod in parent directory" {
  printf 'module test\n' > "$BATS_TMP_DIR/go.mod"
  mkdir -p "$BATS_TMP_DIR/pkg/sub"
  printf 'package sub\n' > "$BATS_TMP_DIR/pkg/sub/foo.go"

  bats_run_zsh "go-module-root $BATS_TMP_DIR/pkg/sub/foo.go"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR" ]]
}

@test "exits 1 when no go.mod found" {
  bats_run_zsh "go-module-root /tmp"
  [[ "$status" -ne 0 ]]
}
