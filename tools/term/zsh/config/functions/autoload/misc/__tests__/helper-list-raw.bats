bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# Argument validation
@test "exits with error when called with no arguments" {
  bats_run_zsh "helper-list-raw"
  [[ "$status" -ne 0 ]]
}

# Output format
@test "outputs 3 fields separated by ▮" {
  bats_run_zsh "helper-list-raw slugify"
  [[ "$status" -eq 0 ]]
  local firstLine="${lines[0]}"
  local fieldCount="$(echo "$firstLine" | awk -F'▮' '{print NF}')"
  [[ "$fieldCount" -eq 3 ]]
}

@test "first field is the helper name" {
  bats_run_zsh "helper-list-raw slugify"
  [[ "$status" -eq 0 ]]
  local firstLine="${lines[0]}"
  local name="${firstLine%%▮*}"
  [[ "$name" == "slugify" ]]
}

@test "third field is an absolute filepath" {
  bats_run_zsh "helper-list-raw slugify"
  [[ "$status" -eq 0 ]]
  local firstLine="${lines[0]}"
  local filepath="$(echo "$firstLine" | awk -F'▮' '{print $3}')"
  [[ "$filepath" == /* ]]
}

# Filtering
@test "returns results for a known helper keyword" {
  bats_run_zsh "helper-list-raw slugify"
  [[ "$status" -eq 0 ]]
  [[ "$output" != "" ]]
}

@test "returns empty output for a nonsense keyword" {
  bats_run_zsh "helper-list-raw zzzzxxxxxnonexistent"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "matches regardless of keyword order" {
  bats_run_zsh "helper-list-raw sort filepaths"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"sort-filepaths"* ]]
}
