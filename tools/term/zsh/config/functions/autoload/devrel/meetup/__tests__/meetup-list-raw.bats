bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw record list to record its arguments, then print canned lines
  airtable-record-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo 'recC▮{"date":"2026-10-20","status":"🛑 Cancelled","name":"Lyon Meetup","URL":"https://lyon.example"}'
    echo 'recA▮{"date":"2026-12-01","status":"⏳️ Pending","name":"Datadog User Group Paris","URL":"https://datadog.example"}'
    echo 'recB▮{"date":"2026-09-15","status":"✅ Confirmed","name":"Paris Meetup"}'
    echo 'recD▮{"date":"2026-03-01","status":"✅ Confirmed","name":"Past Meetup"}'
  }
  # Today is 2026-09-15, after the past Meetup and before the upcoming ones
  date() { echo "2026-09-15"; }
  bats_mock airtable-record-list-raw date
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
  [[ "${lines[2]}" == "recA▮2026-12-01▮pending▮Datadog User Group Paris▮https://datadog.example" ]]
}

@test "shows each status as its label" {
  bats_run_zsh "meetup-list-raw"
  [[ "${lines[0]}" == "recB▮2026-09-15▮confirmed▮Paris Meetup▮" ]]
  [[ "${lines[1]}" == "recC▮2026-10-20▮cancelled▮Lyon Meetup▮https://lyon.example" ]]
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
  [[ "${lines[1]}" == "recC▮"* ]]
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

@test "drops the Meetups before today without any flag" {
  bats_run_zsh "meetup-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "$output" != *"recD"* ]]
}

@test "keeps the Meetup of today" {
  bats_run_zsh "meetup-list-raw"
  [[ "$output" == *"recB▮2026-09-15▮"* ]]
}

@test "prints nothing when no Meetup is upcoming" {
  date() { echo "2027-01-01"; }
  bats_mock date

  bats_run_zsh "meetup-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "applies --limit after the default period" {
  bats_run_zsh "meetup-list-raw --limit 1"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recB▮"* ]]
}

@test "combines the default period with --status" {
  bats_run_zsh "meetup-list-raw --status confirmed"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "recB▮"* ]]
}

@test "sorts the Meetups by date, closest to today first" {
  bats_run_zsh "meetup-list-raw"
  [[ "${lines[0]}" == "recB▮"* ]]
  [[ "${lines[1]}" == "recC▮"* ]]
  [[ "${lines[2]}" == "recA▮"* ]]
}

@test "no longer documents --upcoming" {
  bats_run_zsh "cat \${^fpath}/meetup-list-raw(N)"
  [[ "$output" == *"Fields: recordId"* ]]
  [[ "$output" != *"--upcoming"* ]]
}

# Replace the canned records with Meetups around the edges of 2024, a leap year
stub_period_records() {
  airtable-record-list-raw() {
    echo 'rec01▮{"date":"2023-12-31","status":"✅ Confirmed","name":"A"}'
    echo 'rec02▮{"date":"2024-01-01","status":"✅ Confirmed","name":"B"}'
    echo 'rec03▮{"date":"2024-02-01","status":"✅ Confirmed","name":"C"}'
    echo 'rec04▮{"date":"2024-02-29","status":"✅ Confirmed","name":"D"}'
    echo 'rec05▮{"date":"2024-03-01","status":"✅ Confirmed","name":"E"}'
    echo 'rec06▮{"date":"2024-11-01","status":"✅ Confirmed","name":"F"}'
    echo 'rec07▮{"date":"2024-11-30","status":"⏳️ Pending","name":"G"}'
    echo 'rec08▮{"date":"2024-12-31","status":"✅ Confirmed","name":"H"}'
    echo 'rec09▮{"date":"2025-01-01","status":"✅ Confirmed","name":"I"}'
  }
  bats_mock airtable-record-list-raw
}

@test "starts the list at the full date given to --min-date" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-02-29 --max-date 2024-03-01"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "rec04▮"* ]]
}

@test "expands a month given to --min-date to its first day" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-02 --max-date 2024-02-29"
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "rec03▮"* ]]
}

@test "expands a year given to --min-date to January 1st" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024 --max-date 2024-01-31"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "rec02▮"* ]]
}

@test "lists past Meetups when --min-date is in the past" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-11"
  [[ "${lines[0]}" == "rec06▮"* ]]
  [[ "${lines[1]}" == "rec07▮"* ]]
  [[ "${lines[2]}" == "rec08▮"* ]]
  [[ "${lines[3]}" == "rec09▮"* ]]
}

@test "stops the list at the full date given to --max-date, inclusive" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024 --max-date 2024-02-29"
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[2]}" == "rec04▮"* ]]
}

@test "expands a month given to --max-date to its last day, even in February of a leap year" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024 --max-date 2024-02"
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[2]}" == "rec04▮"* ]]
}

@test "expands a month given to --max-date to its last day, for a month of 30 days" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-11 --max-date 2024-11"
  [[ "${lines[1]}" == "rec07▮"* ]]
}

@test "expands a year given to --max-date to December 31st" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024 --max-date 2024"
  [[ "${#lines[@]}" -eq 7 ]]
  [[ "${lines[6]}" == "rec08▮"* ]]
}

@test "lists a whole month with the same month as minimum and maximum" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-11 --max-date 2024-11"
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "rec06▮"* ]]
  [[ "${lines[1]}" == "rec07▮"* ]]
}

@test "combines the period with --status" {
  stub_period_records

  bats_run_zsh "meetup-list-raw --min-date 2024-11 --max-date 2024-11 --status pending"
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "rec07▮"* ]]
}

@test "has no maximum without --max-date" {
  bats_run_zsh "meetup-list-raw --min-date 2026"
  [[ "${#lines[@]}" -eq 4 ]]
  [[ "${lines[0]}" == "recD▮"* ]]
  [[ "${lines[3]}" == "recA▮"* ]]
}

@test "documents --min-date and --max-date" {
  bats_run_zsh "cat \${^fpath}/meetup-list-raw(N)"
  [[ "$output" == *"--min-date"* ]]
  [[ "$output" == *"--max-date"* ]]
}
