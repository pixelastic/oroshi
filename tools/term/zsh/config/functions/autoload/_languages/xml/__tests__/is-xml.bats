bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .xml file" {
  local file="$BATS_TMP_DIR/foo.xml"
  echo '<root/>' > "$file"
  bats_run_zsh "is-xml $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .json file" {
  local file="$BATS_TMP_DIR/foo.json"
  echo '{}' > "$file"
  bats_run_zsh "is-xml $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory" {
  local dir="$BATS_TMP_DIR/foo.xml"
  mkdir -p "$dir"
  bats_run_zsh "is-xml $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-xml $BATS_TMP_DIR/nonexistent.xml"
  [[ "$status" -eq 1 ]]
}
