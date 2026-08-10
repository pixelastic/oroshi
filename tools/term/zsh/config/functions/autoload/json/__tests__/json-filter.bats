bats_load_library 'helper'

setup() {
  bats_tmp_dir
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

# --- filter by key existence ---

@test "keeps elements that have the key, exit 0" {
  echo '[{"name":"Alice"},{"age":30},{"name":"Bob"}]' > "$JSON_FILE"
  bats_run_zsh "json-filter $JSON_FILE name"
  [[ "$status" -eq 0 ]]
  local result="$(echo "$output" | jq 'length')"
  [[ "$result" = "2" ]]
}

# --- filter by key and value ---

@test "keeps elements where key equals value, exit 0" {
  echo '[{"era":"fantasy"},{"era":"scifi"},{"era":"fantasy"}]' > "$JSON_FILE"
  bats_run_zsh "json-filter $JSON_FILE era fantasy"
  [[ "$status" -eq 0 ]]
  local result="$(echo "$output" | jq 'length')"
  [[ "$result" = "2" ]]
}

@test "returns empty array when no match, exit 0" {
  echo '[{"era":"fantasy"}]' > "$JSON_FILE"
  bats_run_zsh "json-filter $JSON_FILE era scifi"
  [[ "$status" -eq 0 ]]
  local result="$(echo "$output" | jq 'length')"
  [[ "$result" = "0" ]]
}
