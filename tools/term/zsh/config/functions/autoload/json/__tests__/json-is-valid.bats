bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/json/json-is-valid"
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

teardown() {
  bats_cleanup
}

# --- --input flag ---

@test "--input: valid JSON exits 0" {
  echo '{"name":"Alice"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE"
  [ "$status" -eq 0 ]
}

@test "--input: invalid JSON exits 1" {
  echo 'not-json' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE"
  [ "$status" -eq 1 ]
}

# --- stdin ---

@test "stdin: valid JSON exits 0" {
  bats_run_zsh "$CURRENT" <<< '{"key":"value"}'
  [ "$status" -eq 0 ]
}

@test "stdin: invalid JSON exits 1" {
  bats_run_zsh "$CURRENT" <<< 'not-json'
  [ "$status" -eq 1 ]
}
