bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  meetup-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "recA▮2026-12-01▮pending▮Datadog▮https://dd.example"
    echo "recB▮2026-09-15▮confirmed▮Paris Meetup▮"
  }
  # Stub table to record its input, so the width of the terminal never truncates a row
  table() {
    echo "$1" >"$BATS_TMP_DIR/table-input"
  }
  bats_mock meetup-list-raw table
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "gives the rows of the raw list to table, without the record ID" {
  bats_run_zsh "meetup-list; cat \"\$BATS_TMP_DIR/table-input\" | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "2026-12-01▮pending▮Datadog▮https://dd.example" ]]
  [[ "${lines[1]}" == "2026-09-15▮confirmed▮Paris Meetup▮" ]]
}

@test "colors the date and the status" {
  bats_run_zsh "meetup-list; cat \"\$BATS_TMP_DIR/table-input\""
  [[ "${lines[0]}" == *$'\e['*"2026-12-01"* ]]
  [[ "${lines[0]}" == *$'\e['*"pending"* ]]
}

@test "passes the status to the raw list" {
  bats_run_zsh "meetup-list --status confirmed"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --status confirmed" ]]
}

@test "limits the raw list to 10 Meetups by default" {
  bats_run_zsh "meetup-list"
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10" ]]
}

@test "passes the limit given to --limit to the raw list" {
  bats_run_zsh "meetup-list --limit 25"
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 25" ]]
}

@test "prints nothing and exits zero when there is no Meetup" {
  meetup-list-raw() {
    return 0
  }
  bats_mock meetup-list-raw

  bats_run_zsh "meetup-list"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints the error and no row when the raw list fails" {
  meetup-list-raw() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock meetup-list-raw

  bats_run_zsh "meetup-list"
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
  [[ "$output" != *"rec"* ]]
}

@test "passes --upcoming to the raw list" {
  bats_run_zsh "meetup-list --upcoming"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --upcoming" ]]
}

@test "combines --upcoming with the status and the limit" {
  bats_run_zsh "meetup-list --upcoming --status pending --limit 5"
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 5 --status pending --upcoming" ]]
}
