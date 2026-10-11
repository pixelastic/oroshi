bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  airtable-record-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo 'recA▮{"name":"Paris Meetup"}'
    echo "recB▮{}"
  }
  bats_mock airtable-record-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "airtable-record-list --baseId appXXX --tableId Meetups --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--baseId appXXX --tableId Meetups --limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-record-list --baseId appXXX --tableId Meetups | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == 'recA  {"name":"Paris Meetup"}' ]]
  [[ "${lines[1]}" == "recB  {}" ]]
}

@test "colors only the Record ID" {
  bats_run_zsh "airtable-record-list --baseId appXXX --tableId Meetups"
  [[ "${lines[0]}" == $'\e['*"recA"*$'\e[0m  {"name":"Paris Meetup"}' ]]
}

@test "prints nothing and exits non-zero for a Table without Records" {
  airtable-record-list-raw() {
    echo ""
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "airtable-record-list --baseId appXXX --tableId Empty"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-record-list-raw() {
    echo "AIRTABLE_TOKEN is not set" >&2
    return 1
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "airtable-record-list --baseId appXXX --tableId Meetups"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN is not set"* ]]
}
