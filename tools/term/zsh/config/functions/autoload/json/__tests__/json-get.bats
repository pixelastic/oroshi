bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../json-get"
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

teardown() {
  bats_cleanup
}

# --- --input flag ---

@test "--input: scalar read returns value, exit 0" {
  echo '{"name":"Alice"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.name'
  [ "$status" -eq 0 ]
  [ "$output" = "Alice" ]
}

@test "--input: nested key returns value, exit 0" {
  echo '{"a":{"b":"deep"}}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.a.b'
  [ "$status" -eq 0 ]
  [ "$output" = "deep" ]
}

# --- stdin ---

@test "stdin: scalar read returns value, exit 0" {
  local json='{"city":"Paris"}'
  bats_run_zsh "$CURRENT" '.city' <<< "$json"
  [ "$status" -eq 0 ]
  [ "$output" = "Paris" ]
}

# --- array output ---

@test "array: returns one element per line, exit 0" {
  echo '{"tags":["a","b","c"]}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.tags'
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'a\nb\nc')" ]
}

# --- absent / null ---

@test "absent key: empty output, exit 0" {
  echo '{"name":"Alice"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.missing'
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "null value: empty output, exit 0" {
  echo '{"key":null}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.key'
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# --- invalid JSON ---

@test "invalid JSON: exit 1" {
  echo 'not-json' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.key'
  [ "$status" -eq 1 ]
}
