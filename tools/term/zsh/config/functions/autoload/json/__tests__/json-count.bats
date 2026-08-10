bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- file input ---

@test "counts elements in JSON array file, exit 0" {
  echo '[1,2,3]' > "$BATS_TMP_DIR/test.json"
  bats_run_zsh "json-count $BATS_TMP_DIR/test.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "3" ]]
}

@test "empty array returns 0, exit 0" {
  echo '[]' > "$BATS_TMP_DIR/test.json"
  bats_run_zsh "json-count $BATS_TMP_DIR/test.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "0" ]]
}

# --- stdin ---

@test "counts elements from stdin, exit 0" {
  bats_run_zsh "json-count" <<< '[{"a":1},{"b":2}]'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "2" ]]
}
