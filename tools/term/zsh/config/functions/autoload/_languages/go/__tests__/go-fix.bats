bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock goimports: record call, pass through in stdout mode
  goimports() {
    echo "goimports $*" >> "$BATS_TMP_DIR/calls"
    local hasW=0
    for arg in "$@"; do [[ "$arg" == "-w" ]] && hasW=1; done
    [[ $hasW -eq 0 ]] && cat
    return 0
  }
  # Mock gofumpt: record call, pass through in stdout mode
  gofumpt() {
    echo "gofumpt $*" >> "$BATS_TMP_DIR/calls"
    local hasW=0
    for arg in "$@"; do [[ "$arg" == "-w" ]] && hasW=1; done
    [[ $hasW -eq 0 ]] && cat
    return 0
  }
  bats_mock goimports gofumpt
}

@test "in-place by default for a single file" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix $file"
  [[ "$status" -eq 0 ]]
  # No stdout output in in-place mode
  [[ "$output" == "" ]]
  # Both tools called with -w flag
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w $file"* ]]
  [[ "$calls" == *"gofumpt -w $file"* ]]
}

@test "in-place with multiple files" {
  local file1="$BATS_TMP_DIR/a.go"
  local file2="$BATS_TMP_DIR/b.go"
  printf 'package main\n' > "$file1"
  printf 'package main\n' > "$file2"

  bats_run_zsh "go-fix $file1 $file2"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w $file1 $file2"* ]]
  [[ "$calls" == *"gofumpt -w $file1 $file2"* ]]
}

@test "directory expansion in in-place mode" {
  local dir="$BATS_TMP_DIR/pkg"
  mkdir -p "$dir"
  local file1="$dir/a.go"
  local file2="$dir/b.go"
  printf 'package pkg\n' > "$file1"
  printf 'package pkg\n' > "$file2"

  # Mock file-expand to return the two files
  file-expand() {
    printf '%s\n%s\n' "$file1" "$file2"
  }
  bats_mock file-expand

  bats_run_zsh "go-fix $dir"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]

  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w"* ]]
  [[ "$calls" == *"gofumpt -w"* ]]
}

@test "--stdout prints fixed code for single file" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix --stdout $file"
  [[ "$status" -eq 0 ]]
  # Should produce output on stdout
  [[ "$output" != "" ]]
  # Tools called with -w on a temp copy, not the original
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w"* ]]
  [[ "$calls" != *"goimports -w $file"* ]]
}

@test "--stdout errors with multiple files" {
  local file1="$BATS_TMP_DIR/a.go"
  local file2="$BATS_TMP_DIR/b.go"
  printf 'package main\n' > "$file1"
  printf 'package main\n' > "$file2"

  bats_run_zsh "go-fix --stdout $file1 $file2"
  [[ "$status" -ne 0 ]]
}

@test "goimports runs before gofumpt in in-place mode" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix $file"
  [[ "$status" -eq 0 ]]

  # goimports must appear on line 1, gofumpt on line 2
  local firstCall="$(sed -n '1p' "$BATS_TMP_DIR/calls")"
  local secondCall="$(sed -n '2p' "$BATS_TMP_DIR/calls")"
  [[ "$firstCall" == goimports* ]]
  [[ "$secondCall" == gofumpt* ]]
}
