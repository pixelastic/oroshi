bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .svg file" {
  local file="$BATS_TMP_DIR/foo.svg"
  echo '<svg/>' > "$file"
  bats_run_zsh "is-svg $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .json file" {
  local file="$BATS_TMP_DIR/foo.json"
  echo '{}' > "$file"
  bats_run_zsh "is-svg $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory" {
  local dir="$BATS_TMP_DIR/foo.svg"
  mkdir -p "$dir"
  bats_run_zsh "is-svg $dir"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-svg $BATS_TMP_DIR/nonexistent.svg"
  [[ "$status" -eq 1 ]]
}

@test "exits 0 for a symlink to a .svg file" {
  local target="$BATS_TMP_DIR/target.svg"
  local link="$BATS_TMP_DIR/link.svg"
  echo '<svg/>' > "$target"
  ln -s "$target" "$link"
  bats_run_zsh "is-svg $link"
  [[ "$status" -eq 0 ]]
}
