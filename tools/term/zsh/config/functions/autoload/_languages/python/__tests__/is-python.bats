bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .py file" {
  local file="$BATS_TMP_DIR/foo.py"
  echo "print('hi')" > "$file"
  bats_run_zsh "is-python $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .js file" {
  local file="$BATS_TMP_DIR/foo.js"
  echo "console.log('hi')" > "$file"
  bats_run_zsh "is-python $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a file with no extension" {
  local file="$BATS_TMP_DIR/my-script"
  echo "print('hi')" > "$file"
  bats_run_zsh "is-python $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory named foo.py" {
  local dir="$BATS_TMP_DIR/foo.py"
  mkdir -p "$dir"
  bats_run_zsh "is-python $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a path that does not exist" {
  bats_run_zsh "is-python $BATS_TMP_DIR/nonexistent.py"
  [[ "$status" -eq 1 ]]
}
