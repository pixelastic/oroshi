bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned raw list
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo "recABC▮Paris Meetup"
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes base, table, fields, limit and sort to the JS module" {
  bats_run_zsh "airtable-record-list-raw --base DevRel --table Meetups --fields name,date --limit 5 --sort -date"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-list-raw.js DevRel Meetups name,date 5 -date" ]]
}

@test "passes empty fields, limit and sort when they are not given" {
  bats_run_zsh "airtable-record-list-raw --base appXXX --table Meetups"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-list-raw.js appXXX Meetups   " ]]
}

@test "prints the lines of the JS module" {
  bats_run_zsh "airtable-record-list-raw --base DevRel --table Meetups"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "recABC▮Paris Meetup" ]]
}

@test "prints nothing and exits zero for a Table without Records" {
  node() {
    return 0
  }
  bats_mock node

  bats_run_zsh "airtable-record-list-raw --base DevRel --table Empty"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the JS module fails" {
  node() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-record-list-raw --base DevRel --table Meetups"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
