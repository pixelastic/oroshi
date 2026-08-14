bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "produces stable hash for same file" {
  echo "hello world" > "$BATS_TMP_DIR/a.txt"
  bats_run_zsh "file-hash $BATS_TMP_DIR/a.txt"
  local first="$output"

  bats_run_zsh "file-hash $BATS_TMP_DIR/a.txt"
  [[ "$output" = "$first" ]]
}

@test "produces different hash for different content" {
  echo "aaa" > "$BATS_TMP_DIR/a.txt"
  echo "bbb" > "$BATS_TMP_DIR/b.txt"
  bats_run_zsh "file-hash $BATS_TMP_DIR/a.txt"
  local hashA="$output"

  bats_run_zsh "file-hash $BATS_TMP_DIR/b.txt"
  [[ "$output" != "$hashA" ]]
}

@test "produces hash for files smaller than 1 MB" {
  echo "tiny" > "$BATS_TMP_DIR/small.txt"
  bats_run_zsh "file-hash $BATS_TMP_DIR/small.txt"
  [[ "$status" -eq 0 ]]
  [[ -n "$output" ]]
}

@test "produces a 10-char hash" {
  echo "hello" > "$BATS_TMP_DIR/a.txt"
  bats_run_zsh "file-hash $BATS_TMP_DIR/a.txt"
  [[ "$status" -eq 0 ]]
  [[ "${#output}" -eq 10 ]]
}
