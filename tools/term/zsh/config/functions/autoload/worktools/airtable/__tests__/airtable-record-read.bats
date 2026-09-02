bats_load_library 'helper'

setup() {
  export AIRTABLE_TOKEN="test-token-123"
}

@test "returns only requested fields when field list is provided" {
  curl() {
    echo '{"records":[{"id":"recABC","fields":{"name":"Paris Meetup","date":"2026-09-15","location":"Paris"}}]}'
  }
  bats_mock curl

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC --fields name,date"
  [[ "$status" -eq 0 ]]
  expect_json '.name' 'Paris Meetup'
  expect_json '.date' '2026-09-15'
}

@test "returns all fields when no field list is provided" {
  curl() {
    echo '{"records":[{"id":"recABC","fields":{"name":"Paris Meetup","date":"2026-09-15","location":"Paris"}}]}'
  }
  bats_mock curl

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC"
  [[ "$status" -eq 0 ]]
  expect_json '.name' 'Paris Meetup'
  expect_json '.location' 'Paris'
}

@test "outputs valid JSON to stdout" {
  curl() {
    echo '{"records":[{"id":"recABC","fields":{"name":"Paris Meetup"}}]}'
  }
  bats_mock curl

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq empty
}

@test "exits non-zero with error message when record is not found" {
  curl() {
    echo '{"records":[]}'
  }
  bats_mock curl

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recNONEXISTENT"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Record not found"* ]]
}

@test "exits non-zero with error message when token env var is missing" {
  unset AIRTABLE_TOKEN

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN is not set"* ]]
}
