bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$OROSHI_ZSH_AUTOLOAD/json/json-set"
  JSON_FILE="$BATS_TMP_DIR/test.json"
}

teardown() {
  bats_cleanup
}

# --- string (default) ---

@test "write string: key holds new value, other keys unchanged, exits 0" {
  echo '{"name":"old","other":"keep"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.name' 'new'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.name' "$JSON_FILE")" = "new" ]
  [ "$(jq -r '.other' "$JSON_FILE")" = "keep" ]
}

@test "write string: value stored as JSON string, not number" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.val' '42'
  [ "$status" -eq 0 ]
  [ "$(jq 'type' "$JSON_FILE")" = '"object"' ]
  [ "$(jq '.val | type' "$JSON_FILE")" = '"string"' ]
  [ "$(jq -r '.val' "$JSON_FILE")" = "42" ]
}

# --- --number flag ---

@test "write number: --number stores value as JSON number" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.count' '42' --number
  [ "$status" -eq 0 ]
  [ "$(jq '.count | type' "$JSON_FILE")" = '"number"' ]
  [ "$(jq '.count' "$JSON_FILE")" = "42" ]
}

# --- --array flag ---

@test "write array: --array reads lines from stdin as JSON array" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.tags' --array <<< $'a\nb\nc'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.tags | type' "$JSON_FILE")" = "array" ]
  [ "$(jq -r '.tags[]' "$JSON_FILE")" = "$(printf 'a\nb\nc')" ]
}

# --- value from stdin (no third arg) ---

@test "value from stdin: third arg omitted reads value from stdin" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.name' <<< 'tim'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.name' "$JSON_FILE")" = "tim" ]
}

# --- file creation ---

@test "file absent: file is created with the written key" {
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.name' 'created'
  [ "$status" -eq 0 ]
  [ -f "$JSON_FILE" ]
  [ "$(jq -r '.name' "$JSON_FILE")" = "created" ]
}

# --- --bool flag ---

@test "--bool: 'true' stored as JSON boolean true, exits 0" {
  echo '{"other":"keep"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.enabled' 'true' --bool
  [ "$status" -eq 0 ]
  [ "$(jq '.enabled | type' "$JSON_FILE")" = '"boolean"' ]
  [ "$(jq '.enabled' "$JSON_FILE")" = "true" ]
  [ "$(jq -r '.other' "$JSON_FILE")" = "keep" ]
}

@test "--bool: 'false' stored as JSON boolean false, exits 0" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.enabled' 'false' --bool
  [ "$status" -eq 0 ]
  [ "$(jq '.enabled | type' "$JSON_FILE")" = '"boolean"' ]
  [ "$(jq '.enabled' "$JSON_FILE")" = "false" ]
}

# --- --null flag ---

@test "--null: key is set to JSON null, exits 0" {
  echo '{"name":"alice","other":"keep"}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.name' --null
  [ "$status" -eq 0 ]
  [ "$(jq '.name' "$JSON_FILE")" = "null" ]
  [ "$(jq -r '.other' "$JSON_FILE")" = "keep" ]
}

@test "--null: any value arg is discarded" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.key' 'ignored' --null
  [ "$status" -eq 0 ]
  [ "$(jq '.key' "$JSON_FILE")" = "null" ]
}

# --- nested path ---

@test "nested path: intermediate keys created when absent" {
  echo '{}' > "$JSON_FILE"
  bats_run_zsh "$CURRENT" --input "$JSON_FILE" '.a.b.c' 'deep'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.a.b.c' "$JSON_FILE")" = "deep" ]
}
