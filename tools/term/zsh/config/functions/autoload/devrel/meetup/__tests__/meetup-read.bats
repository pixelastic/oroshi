bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the record read to record its arguments, then print a canned Record
  airtable-record-read() {
    print -r -- "$@" >"$BATS_TMP_DIR/read-args"
    echo '{"name":"Datadog User Group Paris","date":"2026-12-01","image":[{"id":"attA","filename":"logo.png"}]}'
  }
  bats_mock airtable-record-read
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "AIRTABLE_BASE_DEVREL" "appDEV"
}

@test "reads the Record from the Meetups Table of the DevRel Base" {
  bats_run_zsh "meetup-read recXXX"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/read-args")" == "--base appDEV --table Meetups --record recXXX" ]]
}

@test "prints the Fields as JSON, including the Attachment IDs" {
  bats_run_zsh "meetup-read recXXX"
  expect_json '.name' 'Datadog User Group Paris'
  expect_json '.image[0].id' 'attA'
}

@test "prints a usage error when the Record ID is missing" {
  bats_run_zsh "meetup-read"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
  [[ ! -f "$BATS_TMP_DIR/read-args" ]]
}

@test "exits non-zero when AIRTABLE_BASE_DEVREL is not set" {
  bats_mock_env "AIRTABLE_BASE_DEVREL" ""

  bats_run_zsh "meetup-read recXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_BASE_DEVREL"* ]]
  [[ ! -f "$BATS_TMP_DIR/read-args" ]]
}

@test "exits non-zero when the record read fails" {
  airtable-record-read() {
    echo "Record not found" >&2
    return 1
  }
  bats_mock airtable-record-read

  bats_run_zsh "meetup-read recXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Record not found"* ]]
}
