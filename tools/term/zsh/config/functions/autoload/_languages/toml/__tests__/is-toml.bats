bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "exits 0 for a .toml file" {
  local file="$BATS_TMP_DIR/foo.toml"
  echo 'key = "value"' > "$file"
  bats_run_zsh "is-toml $file"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 for a .json file" {
  local file="$BATS_TMP_DIR/foo.json"
  echo '{}' > "$file"
  bats_run_zsh "is-toml $file"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a missing file" {
  bats_run_zsh "is-toml $BATS_TMP_DIR/nonexistent.toml"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 for a directory" {
  local dir="$BATS_TMP_DIR/foo.toml"
  mkdir -p "$dir"
  bats_run_zsh "is-toml $dir"
  [[ "$status" -eq 1 ]]
}
