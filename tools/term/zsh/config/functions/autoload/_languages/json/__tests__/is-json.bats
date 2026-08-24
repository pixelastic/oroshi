bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .json file" {
  local file="$BATS_TMP_DIR/foo.json"
  echo '{}' > "$file"
  bats_run_zsh "is-json $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .js file" {
  local file="$BATS_TMP_DIR/foo.js"
  echo 'var x = 1' > "$file"
  bats_run_zsh "is-json $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory" {
  local dir="$BATS_TMP_DIR/foo.json"
  mkdir -p "$dir"
  bats_run_zsh "is-json $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-json $BATS_TMP_DIR/nonexistent.json"
  [[ "$status" -eq 1 ]]
}
