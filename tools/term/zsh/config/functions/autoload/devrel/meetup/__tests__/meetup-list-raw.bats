bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw record list to record its arguments, then print canned lines
  airtable-record-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "recA▮2026-12-01▮⏳️ Pending▮Datadog User Group Paris▮https://datadog.example"
    echo "recB▮2026-09-15▮✅ Confirmed▮Paris Meetup▮"
    echo "recC▮2026-06-01▮🛑 Cancelled▮Lyon Meetup▮https://lyon.example"
  }
  bats_mock airtable-record-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "AIRTABLE_BASE_DEVREL" "appDEV"
}

@test "lists the Meetups Table of the DevRel Base, most recent first" {
  bats_run_zsh "meetup-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--base appDEV --table Meetups --fields date,status,name,URL --sort -date" ]]
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

@test "prints nothing and exits zero when no Meetup has that status" {
  airtable-record-list-raw() {
    echo "recA▮2026-12-01▮⏳️ Pending▮Datadog User Group Paris▮"
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
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "meetup-list-raw"
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
  [[ "$output" != *"recA"* ]]
}
