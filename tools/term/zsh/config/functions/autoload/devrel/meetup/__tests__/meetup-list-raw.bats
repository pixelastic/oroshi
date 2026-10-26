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

@test "fails on a month 13 and names the value" {
  bats_run_zsh "meetup-list-raw --min-date 2024-13"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"2024-13"* ]]
}

@test "fails on a word such as nov" {
  bats_run_zsh "meetup-list-raw --min-date nov"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"nov"* ]]
}

@test "fails on a day that does not exist" {
  bats_run_zsh "meetup-list-raw --min-date 2026-02-30"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"2026-02-30"* ]]
}

@test "fails on the 29th of February of a common year" {
  bats_run_zsh "meetup-list-raw --min-date 2025-02-29"
  [[ "$status" -eq 1 ]]
}

@test "accepts the 29th of February of a leap year" {
  bats_run_zsh "meetup-list-raw --min-date 2024-02-29"
  [[ "$status" -eq 0 ]]
}

@test "fails on an invalid --max-date too" {
  bats_run_zsh "meetup-list-raw --max-date 2024-13"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"2024-13"* ]]
}

@test "fails when --min-date is later than --max-date" {
  bats_run_zsh "meetup-list-raw --min-date 2024-12 --max-date 2024-11"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"2024-12"* ]]
  [[ "$output" == *"2024-11"* ]]
}

@test "accepts a --min-date equal to --max-date" {
  bats_run_zsh "meetup-list-raw --min-date 2024-11-15 --max-date 2024-11-15"
  [[ "$status" -eq 0 ]]
}

@test "sends no request when a date is invalid" {
  bats_run_zsh "meetup-list-raw --min-date 2024-13"
  [[ ! -f "$BATS_TMP_DIR/raw-args" ]]
}

@test "sends no request when --min-date is later than --max-date" {
  bats_run_zsh "meetup-list-raw --min-date 2024-12 --max-date 2024-11"
  [[ ! -f "$BATS_TMP_DIR/raw-args" ]]
}

# Replace the canned records with 2027 Meetups, the first 3 cancelled, the others confirmed
# Usage: stub_many_records 30
stub_many_records() {
  airtable-record-list-raw() {
    local label
    for meetupNumber in $(seq 1 "$STUB_COUNT"); do
      label="✅ Confirmed"
      [[ "$meetupNumber" -le 3 ]] && label="🛑 Cancelled"
      printf 'rec%02d▮{"date":"2027-01-%02d","status":"%s","name":"M%02d"}\n' "$meetupNumber" "$meetupNumber" "$label" "$meetupNumber"
    done
  }
  bats_mock airtable-record-list-raw
  bats_mock_env "STUB_COUNT" "$1"
}

@test "keeps the first 25 Meetups without any flag" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw 2>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 25 ]]
  [[ "${lines[0]}" == "rec01▮"* ]]
  [[ "${lines[24]}" == "rec25▮"* ]]
}

@test "applies the default limit after the status filter" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --status confirmed 2>/dev/null"
  [[ "${#lines[@]}" -eq 25 ]]
  [[ "${lines[0]}" == "rec04▮"* ]]
  [[ "${lines[24]}" == "rec28▮"* ]]
}

@test "lists every match with --min-date" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --min-date 2027"
  [[ "${#lines[@]}" -eq 30 ]]
}

@test "lists every match with --max-date" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --max-date 2027"
  [[ "${#lines[@]}" -eq 30 ]]
}

@test "keeps the first 3 Meetups with --limit 3" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --limit 3"
  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[2]}" == "rec03▮"* ]]
}

@test "applies an explicit limit together with a date flag" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --min-date 2027 --limit 4"
  [[ "${#lines[@]}" -eq 4 ]]
  [[ "${lines[3]}" == "rec04▮"* ]]
}

@test "warns on stderr when the default limit hides Meetups" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw >/dev/null"
  [[ "$output" == *"More meetups exist, raise --limit"* ]]
}

@test "keeps stdout free of the warning" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw 2>/dev/null"
  [[ "$output" != *"More meetups"* ]]
}

@test "does not warn when exactly 25 Meetups match" {
  stub_many_records 25

  bats_run_zsh "meetup-list-raw"
  [[ "${#lines[@]}" -eq 25 ]]
  [[ "$output" != *"More meetups"* ]]
}

@test "does not warn with an explicit limit" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --limit 3"
  [[ "$output" != *"More meetups"* ]]
}

@test "does not warn with a date flag" {
  stub_many_records 30

  bats_run_zsh "meetup-list-raw --min-date 2027"
  [[ "$output" != *"More meetups"* ]]
}

@test "documents the limit rules" {
  bats_run_zsh "cat \${^fpath}/meetup-list-raw(N)"
  [[ "$output" == *"default: 25"* ]]
  [[ "$output" == *"More meetups exist"* ]]
}
