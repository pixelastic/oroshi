bats_load_library 'helper'

setup() {
  bats_tmp_dir
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

# --- argument ---

@test "argument: pretty-prints JSON, exit 0" {
  input='{"name":"Alice"}'
  expected='{
  "name": "Alice"
}'
  bats_run_zsh "json-pretty '$input'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "argument: invalid JSON exits 1" {
  input='not-json'
  bats_run_zsh "json-pretty '$input'"
  [ "$status" -eq 1 ]
}

# --- stdin ---

@test "stdin: pretty-prints JSON, exit 0" {
  input='{"city":"Paris"}'
  expected='{
  "city": "Paris"
}'
  bats_run_zsh "echo '$input' | json-pretty"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

# --- --input flag ---

@test "--input: pretty-prints JSON from file, exit 0" {
  input='{"lang":"zsh"}'
  expected='{
  "lang": "zsh"
}'
  echo "$input" > "$JSON_FILE"
  bats_run_zsh "json-pretty --input '$JSON_FILE'"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "--input: invalid JSON exits 1" {
  input='not-json'
  echo "$input" > "$JSON_FILE"
  bats_run_zsh "json-pretty --input '$JSON_FILE'"
  [ "$status" -eq 1 ]
}
