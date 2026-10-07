bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  airtable-record-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "recA▮Paris Meetup▮Paris▯France"
    echo "recB▮Lyon Meetup▮"
  }
  bats_mock airtable-record-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes base, table, fields, limit and sort to the raw list" {
  bats_run_zsh "airtable-record-list --base DevRel --table Meetups --fields name,date --limit 5 --sort -date"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--base DevRel --table Meetups --fields name,date --limit 5 --sort -date" ]]
}

@test "only passes the options it was given to the raw list" {
  bats_run_zsh "airtable-record-list --base DevRel --table Meetups"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--base DevRel --table Meetups" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-record-list --base DevRel --table Meetups --fields name,city | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "recA  Paris Meetup  Paris, France" ]]
  # table pads the empty last column with spaces
  local pattern="^recB  Lyon Meetup *$"
  [[ "${lines[1]}" =~ $pattern ]]
}

@test "colors the record ID" {
  bats_run_zsh "airtable-record-list --base DevRel --table Meetups"
  [[ "${lines[0]}" == *$'\e['*"recA"* ]]
}

@test "prints nothing and exits zero for a Table without Records" {
  airtable-record-list-raw() {
    return 0
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "airtable-record-list --base DevRel --table Empty"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-record-list-raw() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock airtable-record-list-raw

  bats_run_zsh "airtable-record-list --base DevRel --table Meetups"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
