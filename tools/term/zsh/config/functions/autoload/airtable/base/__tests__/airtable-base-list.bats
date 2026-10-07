bats_load_library 'helper'

setup() {
  # Stub the raw list to print canned lines
  airtable-base-list-raw() {
    echo "appABC▮DevRel"
    echo "appDEF▮Other Base"
  }
  bats_mock airtable-base-list-raw
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-base-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "appABC  DevRel" ]]
  [[ "${lines[1]}" == "appDEF  Other Base" ]]
}

@test "colors the Base ID" {
  bats_run_zsh "airtable-base-list"
  [[ "${lines[0]}" == *$'\e['*"appABC"* ]]
}

@test "prints nothing and exits zero when no Base is accessible" {
  airtable-base-list-raw() {
    return 0
  }
  bats_mock airtable-base-list-raw

  bats_run_zsh "airtable-base-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-base-list-raw() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock airtable-base-list-raw

  bats_run_zsh "airtable-base-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
