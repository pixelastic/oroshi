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

@test "gives the rows of the raw list to table, in the same columns" {
  bats_run_zsh "meetup-list; cat \"\$BATS_TMP_DIR/table-input\" | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "recA▮2026-12-01▮pending▮Datadog▮https://dd.example" ]]
  [[ "${lines[1]}" == "recB▮2026-09-15▮confirmed▮Paris Meetup▮" ]]
}

@test "colors the record ID, the date and the status" {
  bats_run_zsh "meetup-list; cat \"\$BATS_TMP_DIR/table-input\""
  [[ "${lines[0]}" == *$'\e['*"recA"* ]]
  [[ "${lines[0]}" == *$'\e['*"2026-12-01"* ]]
  [[ "${lines[0]}" == *$'\e['*"pending"* ]]
}

@test "passes the status to the raw list" {
  bats_run_zsh "meetup-list --status confirmed"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--status confirmed" ]]
}

@test "passes nothing to the raw list without a status" {
  bats_run_zsh "meetup-list"
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "" ]]
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
