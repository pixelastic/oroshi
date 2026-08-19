bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock goimports: record call, pass through in stdin mode
  goimports() {
    echo "goimports $*" >> "$BATS_TMP_DIR/calls"
    local hasW=0
    for arg in "$@"; do [[ "$arg" == "-w" ]] && hasW=1; done
    [[ $hasW -eq 0 ]] && cat
    return 0
  }
  # Mock gofumpt: record call, pass through in stdin mode
  gofumpt() {
    echo "gofumpt $*" >> "$BATS_TMP_DIR/calls"
    local hasW=0
    for arg in "$@"; do [[ "$arg" == "-w" ]] && hasW=1; done
    [[ $hasW -eq 0 ]] && cat
    return 0
  }
  bats_mock goimports gofumpt
}

@test "file to stdout by default" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix $file"
  [[ "$status" -eq 0 ]]
  # Should produce output on stdout
  [[ "$output" != "" ]]
  # Tools called without -w
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" != *"-w"* ]]
}

@test "--in-place modifies file with -w" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix --in-place $file"
  [[ "$status" -eq 0 ]]

  # Both tools called with -w flag
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w $file"* ]]
  [[ "$calls" == *"gofumpt -w $file"* ]]
}

@test "--in-place with multiple files" {
  local file1="$BATS_TMP_DIR/a.go"
  local file2="$BATS_TMP_DIR/b.go"
  printf 'package main\n' > "$file1"
  printf 'package main\n' > "$file2"

  bats_run_zsh "go-fix --in-place $file1 $file2"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -w $file1 $file2"* ]]
  [[ "$calls" == *"gofumpt -w $file1 $file2"* ]]
}

@test "stdin mode with --filepath writes to stdout and passes -srcdir" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix --filepath $file" <<< "package main"
  [[ "$status" -eq 0 ]]
  [[ "$output" != "" ]]
  # goimports receives -srcdir for import resolution
  local calls="$(cat "$BATS_TMP_DIR/calls")"
  [[ "$calls" == *"goimports -srcdir $file"* ]]
}

@test "goimports runs before gofumpt in --in-place mode" {
  local file="$BATS_TMP_DIR/main.go"
  printf 'package main\n' > "$file"

  bats_run_zsh "go-fix --in-place $file"
  [[ "$status" -eq 0 ]]

  # goimports must appear on line 1, gofumpt on line 2
  local firstCall="$(sed -n '1p' "$BATS_TMP_DIR/calls")"
  local secondCall="$(sed -n '2p' "$BATS_TMP_DIR/calls")"
  [[ "$firstCall" == goimports* ]]
  [[ "$secondCall" == gofumpt* ]]
}
