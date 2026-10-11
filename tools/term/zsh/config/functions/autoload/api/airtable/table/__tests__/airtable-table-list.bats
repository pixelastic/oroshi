bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  airtable-table-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "tblABC▮Meetups"
    echo "tblDEF▮Speakers and Talks"
  }
  bats_mock airtable-table-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "airtable-table-list --baseId appXXX --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--baseId appXXX --limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-table-list --baseId appXXX | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "tblABC  Meetups" ]]
  [[ "${lines[1]}" == "tblDEF  Speakers and Talks" ]]
}

@test "colors only the Table ID" {
  bats_run_zsh "airtable-table-list --baseId appXXX"
  [[ "${lines[0]}" == $'\e['*"tblABC"*$'\e[0m  Meetups' ]]
}

@test "prints nothing and exits non-zero for a Base without Tables" {
  airtable-table-list-raw() {
    echo ""
  }
  bats_mock airtable-table-list-raw

  bats_run_zsh "airtable-table-list --baseId appXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-table-list-raw() {
    echo "AIRTABLE_TOKEN is not set" >&2
    return 1
  }
  bats_mock airtable-table-list-raw

  bats_run_zsh "airtable-table-list --baseId appXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN is not set"* ]]
}
