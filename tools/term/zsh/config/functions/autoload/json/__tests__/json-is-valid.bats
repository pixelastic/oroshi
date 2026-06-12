bats_load_library 'helper'

setup() {
  bats_tmp_dir
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

teardown() {
  bats_cleanup
}

# --- --input flag ---

@test "--input: valid JSON exits 0" {
  echo '{"name":"Alice"}' > "$JSON_FILE"
  bats_run_zsh "json-is-valid --input $JSON_FILE"
  [ "$status" -eq 0 ]
}

@test "--input: invalid JSON exits 1" {
  echo 'not-json' > "$JSON_FILE"
  bats_run_zsh "json-is-valid --input $JSON_FILE"
  [ "$status" -eq 1 ]
}

# --- stdin ---

@test "stdin: valid JSON exits 0" {
  json='{"name":"Alice"}'
  bats_run_zsh "json-is-valid <<< '$json'"
  [ "$status" -eq 0 ]
}

@test "stdin: invalid JSON exits 1" {
  json='not_json'
  bats_run_zsh "json-is-valid <<< '$json'"
  [ "$status" -eq 1 ]
}
