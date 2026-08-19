bats_load_library 'helper'

@test "converts arguments to JSON array" {
  bats_run_zsh 'json-array "foo" "bar"'
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0]')" == "foo" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1]')" == "bar" ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "2" ]]
}

@test "no arguments: returns empty array" {
  bats_run_zsh "json-array"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "single argument" {
  bats_run_zsh 'json-array "hello"'
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0]')" == "hello" ]]
  [[ "$(printf '%s' "$output" | jq 'length')" == "1" ]]
}

@test "preserves special characters" {
  bats_run_zsh 'json-array "main.go:" "pkg/" ""'
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[0]')" == "main.go:" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[1]')" == "pkg/" ]]
  [[ "$(printf '%s' "$output" | jq -r '.[2]')" == "" ]]
}
