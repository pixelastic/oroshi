bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned record
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo '{"name":"Paris Meetup"}'
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes base, table, record and fields to the JS module" {
  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC --fields name,date"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-read.js appXXX Meetups recABC name,date" ]]
}

@test "passes an empty field list when --fields is not given" {
  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-read.js appXXX Meetups recABC "* ]]
}

@test "prints the JSON of the JS module" {
  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recABC"
  expect_json '.name' 'Paris Meetup'
}

@test "exits non-zero when the JS module fails" {
  node() {
    echo "Record not found" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-record-read --base appXXX --table Meetups --record recNONE"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Record not found"* ]]
}
