bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns parent directory for a single file" {
  local file="$BATS_TMP_DIR/a/b/file.txt"
  mkdir -p "$BATS_TMP_DIR/a/b"
  touch "$file"

  bats_run_zsh "path-common-ancestor $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/a/b" ]]
}

@test "returns common ancestor of two files in sibling directories" {
  mkdir -p "$BATS_TMP_DIR/a/b" "$BATS_TMP_DIR/a/c"
  touch "$BATS_TMP_DIR/a/b/x.txt" "$BATS_TMP_DIR/a/c/y.txt"

  bats_run_zsh "path-common-ancestor $BATS_TMP_DIR/a/b/x.txt $BATS_TMP_DIR/a/c/y.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/a" ]]
}

@test "returns common ancestor of files at different depths" {
  mkdir -p "$BATS_TMP_DIR/a/b/c/d" "$BATS_TMP_DIR/a/b"
  touch "$BATS_TMP_DIR/a/b/c/d/deep.txt" "$BATS_TMP_DIR/a/b/shallow.txt"

  bats_run_zsh "path-common-ancestor $BATS_TMP_DIR/a/b/c/d/deep.txt $BATS_TMP_DIR/a/b/shallow.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/a/b" ]]
}

@test "returns same directory for two files in same directory" {
  mkdir -p "$BATS_TMP_DIR/dir"
  touch "$BATS_TMP_DIR/dir/a.txt" "$BATS_TMP_DIR/dir/b.txt"

  bats_run_zsh "path-common-ancestor $BATS_TMP_DIR/dir/a.txt $BATS_TMP_DIR/dir/b.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/dir" ]]
}

@test "returns common ancestor of three files" {
  mkdir -p "$BATS_TMP_DIR/a/x" "$BATS_TMP_DIR/a/y" "$BATS_TMP_DIR/a/z"
  touch "$BATS_TMP_DIR/a/x/1.txt" "$BATS_TMP_DIR/a/y/2.txt" "$BATS_TMP_DIR/a/z/3.txt"

  bats_run_zsh "path-common-ancestor $BATS_TMP_DIR/a/x/1.txt $BATS_TMP_DIR/a/y/2.txt $BATS_TMP_DIR/a/z/3.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR/a" ]]
}

@test "does not match partial directory names" {
  mkdir -p "$BATS_TMP_DIR/abc" "$BATS_TMP_DIR/abcd"
  touch "$BATS_TMP_DIR/abc/x.txt" "$BATS_TMP_DIR/abcd/y.txt"

  bats_run_zsh "path-common-ancestor $BATS_TMP_DIR/abc/x.txt $BATS_TMP_DIR/abcd/y.txt"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$BATS_TMP_DIR" ]]
}

@test "errors when no arguments" {
  bats_run_zsh "path-common-ancestor"
  [[ "$status" -eq 1 ]]
}
