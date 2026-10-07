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

@test "passes the Base to the raw list" {
  bats_run_zsh "airtable-table-list --base appXXX"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--base appXXX" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-table-list --base appXXX | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "tblABC  Meetups" ]]
  [[ "${lines[1]}" == "tblDEF  Speakers and Talks" ]]
}

@test "colors the Table ID" {
  bats_run_zsh "airtable-table-list --base appXXX"
  [[ "${lines[0]}" == *$'\e['*"tblABC"* ]]
}

@test "prints nothing and exits zero for a Base without Tables" {
  airtable-table-list-raw() {
    return 0
  }
  bats_mock airtable-table-list-raw

  bats_run_zsh "airtable-table-list --base appXXX"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-table-list-raw() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock airtable-table-list-raw

  bats_run_zsh "airtable-table-list --base appXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
