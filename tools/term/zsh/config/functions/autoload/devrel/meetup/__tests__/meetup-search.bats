bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the record search to record its arguments, then print a canned result
  airtable-record-search() {
    print -r -- "$@" >"$BATS_TMP_DIR/search-args"
    echo '[{"id":"recA","fields":{"name":"Datadog User Group Paris"}}]'
  }
  bats_mock airtable-record-search
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "AIRTABLE_BASE_DEVREL" "appDEV"
}

@test "searches the name of the Meetups Table of the DevRel Base" {
  bats_run_zsh "meetup-search datadog"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/search-args")" == "--base appDEV --table Meetups --in name datadog" ]]
}

@test "returns the matching Meetups as JSON" {
  bats_run_zsh "meetup-search datadog"
  expect_json '.[0].id' 'recA'
  expect_json '.[0].fields.name' 'Datadog User Group Paris'
}

@test "prints an empty JSON array when nothing matches" {
  airtable-record-search() {
    echo '[]'
  }
  bats_mock airtable-record-search

  bats_run_zsh "meetup-search nothing"
  [[ "$status" -eq 0 ]]
  expect_json 'length' '0'
}

@test "prints a usage error when the search text is missing" {
  bats_run_zsh "meetup-search"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: meetup-search"* ]]
  [[ ! -f "$BATS_TMP_DIR/search-args" ]]
}

@test "exits non-zero when AIRTABLE_BASE_DEVREL is not set" {
  bats_mock_env "AIRTABLE_BASE_DEVREL" ""

  bats_run_zsh "meetup-search datadog"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_BASE_DEVREL"* ]]
  [[ ! -f "$BATS_TMP_DIR/search-args" ]]
}

@test "exits non-zero when the record search fails" {
  airtable-record-search() {
    echo "Invalid formula" >&2
    return 1
  }
  bats_mock airtable-record-search

  bats_run_zsh "meetup-search datadog"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid formula"* ]]
}
