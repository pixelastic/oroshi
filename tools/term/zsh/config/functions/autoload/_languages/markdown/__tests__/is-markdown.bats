bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .md file" {
  local file="$BATS_TMP_DIR/foo.md"
  echo '# Title' > "$file"
  bats_run_zsh "is-markdown $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits 1 for a .markdown file" {
  local file="$BATS_TMP_DIR/foo.markdown"
  echo '# Title' > "$file"
  bats_run_zsh "is-markdown $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a non-Markdown file" {
  local file="$BATS_TMP_DIR/foo.txt"
  echo 'hello' > "$file"
  bats_run_zsh "is-markdown $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory" {
  local dir="$BATS_TMP_DIR/foo.md"
  mkdir -p "$dir"
  bats_run_zsh "is-markdown $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-markdown $BATS_TMP_DIR/nonexistent.md"
  [[ "$status" -eq 1 ]]
}
