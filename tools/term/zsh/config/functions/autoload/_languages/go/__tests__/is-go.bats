bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .go file" {
  local file="$BATS_TMP_DIR/foo.go"
  echo "package main" > "$file"
  bats_run_zsh "is-go $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 0 for a _test.go file" {
  local file="$BATS_TMP_DIR/foo_test.go"
  echo "package main" > "$file"
  bats_run_zsh "is-go $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .py file" {
  local file="$BATS_TMP_DIR/foo.py"
  echo "print('hi')" > "$file"
  bats_run_zsh "is-go $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a file with no extension" {
  local file="$BATS_TMP_DIR/my-script"
  echo "package main" > "$file"
  bats_run_zsh "is-go $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory named foo.go" {
  local dir="$BATS_TMP_DIR/foo.go"
  mkdir -p "$dir"
  bats_run_zsh "is-go $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a path that does not exist" {
  bats_run_zsh "is-go $BATS_TMP_DIR/nonexistent.go"
  [[ "$status" -eq 1 ]]
}
