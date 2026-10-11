bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw record list to record its arguments, then print canned lines
  airtable-record-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo 'recC▮{"date":"2026-06-01","status":"🛑 Cancelled","name":"Lyon Meetup","URL":"https://lyon.example"}'
    echo 'recA▮{"date":"2026-12-01","status":"⏳️ Pending","name":"Datadog User Group Paris","URL":"https://datadog.example"}'
    echo 'recB▮{"date":"2026-09-15","status":"✅ Confirmed","name":"Paris Meetup"}'
  }
  bats_mock airtable-record-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "AIRTABLE_BASE_DEVREL" "appDEV"
}

@test "lists the Meetups Table of the DevRel Base" {
  bats_run_zsh "meetup-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--baseId appDEV --tableId Meetups --limit 1000" ]]
}

@test "prints record ID, date, status, name and URL, in that order" {
  bats_run_zsh "meetup-list-raw"
  [[ "${lines[0]}" == "recA▮2026-12-01▮pending▮Datadog User Group Paris▮https://datadog.example" ]]
}

@test "shows each status as its label" {
  bats_run_zsh "meetup-list-raw"
  [[ "${lines[1]}" == "recB▮2026-09-15▮confirmed▮Paris Meetup▮" ]]
  [[ "${lines[2]}" == "recC▮2026-06-01▮cancelled▮Lyon Meetup▮https://lyon.example" ]]
}

@test "keeps only the Meetups with the status given to --status" {
  bats_run_zsh "meetup-list-raw --status confirmed"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recB▮"* ]]
}

@test "keeps only the first Meetups up to --limit" {
  bats_run_zsh "meetup-list-raw --limit 2"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[1]}" == "recB▮"* ]]
}

@test "applies --limit after the status filter" {
  bats_run_zsh "meetup-list-raw --status cancelled --limit 1"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recC▮"* ]]
}

@test "prints nothing and exits zero when no Meetup has that status" {
  airtable-record-list-raw() {
    echo 'recA▮{"date":"2026-12-01","status":"⏳️ Pending","name":"Datadog User Group Paris"}'
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "meetup-list-raw --status cancelled"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "fails on an unknown status before any request" {
  bats_run_zsh "meetup-list-raw --status paused"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"paused"* ]]
  [[ ! -f "$BATS_TMP_DIR/raw-args" ]]
}

@test "exits non-zero when AIRTABLE_BASE_DEVREL is not set" {
  bats_mock_env "AIRTABLE_BASE_DEVREL" ""

  bats_run_zsh "meetup-list-raw"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_BASE_DEVREL"* ]]
  [[ ! -f "$BATS_TMP_DIR/raw-args" ]]
}

@test "prints the error and no row when the raw record list fails" {
  airtable-record-list-raw() {
    echo "AIRTABLE_TOKEN is not set" >&2
    return 1
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "meetup-list-raw"
  [[ "$output" == *"AIRTABLE_TOKEN is not set"* ]]
  [[ "$output" != *"recA"* ]]
}

@test "keeps only the Meetups of today or later with --upcoming" {
  date() { echo "2026-09-15"; }
  bats_mock date

  bats_run_zsh "meetup-list-raw --upcoming"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "recA▮"* ]]
  [[ "${lines[1]}" == "recB▮"* ]]
}

@test "prints nothing when no Meetup is upcoming" {
  date() { echo "2027-01-01"; }
  bats_mock date

  bats_run_zsh "meetup-list-raw --upcoming"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "applies --limit after --upcoming" {
  date() { echo "2026-09-15"; }
  bats_mock date

  bats_run_zsh "meetup-list-raw --upcoming --limit 1"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recA▮"* ]]
}

@test "combines --upcoming with --status" {
  date() { echo "2026-09-15"; }
  bats_mock date

  bats_run_zsh "meetup-list-raw --upcoming --status confirmed"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recB▮"* ]]
}

@test "sorts the Meetups by date, most recent first" {
  bats_run_zsh "meetup-list-raw"
  [[ "${lines[0]}" == "recA▮"* ]]
  [[ "${lines[1]}" == "recB▮"* ]]
  [[ "${lines[2]}" == "recC▮"* ]]
}
