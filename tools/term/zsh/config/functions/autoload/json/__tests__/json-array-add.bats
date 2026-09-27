bats_load_library 'helper'

setup() {
  bats_tmp_dir
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

@test "appends a string to an existing array" {
  echo '["one"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' 'two'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["one","two"]' ]]
}

@test "creates the file and its parent dirs with the value when absent" {
  local newFile="$BATS_TMP_DIR/sub/dir/new.json"
  bats_run_zsh "json-array-add --input '$newFile' 'one'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$newFile")" = '["one"]' ]]
}

@test "appends duplicates by default" {
  echo '["one"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' 'one'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["one","one"]' ]]
}

@test "--unique does not add a value already present" {
  echo '["one","two"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' --unique 'one'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["one","two"]' ]]
}

@test "--unique also removes duplicates already in the file" {
  echo '["one","two","one"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' --unique 'three'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["one","three","two"]' ]]
}

@test "--unique sorts the array" {
  echo '["zeta","alpha"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' --unique 'beta'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["alpha","beta","zeta"]' ]]
}

@test "stores the value as a JSON string" {
  echo '[]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' '42'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["42"]' ]]
}

@test "fails without --input" {
  bats_run_zsh "json-array-add 'one'"
  [[ "$status" -eq 1 ]]
}

@test "fails without a value and leaves the file untouched" {
  echo '["one"]' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE'"
  [[ "$status" -eq 1 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '["one"]' ]]
}

@test "fails on a file that is not an array and leaves it untouched" {
  echo '{"key":"value"}' > "$JSON_FILE"
  bats_run_zsh "json-array-add --input '$JSON_FILE' 'one'"
  [[ "$status" -ne 0 ]]
  [[ "$(jq --compact-output '.' "$JSON_FILE")" = '{"key":"value"}' ]]
}
