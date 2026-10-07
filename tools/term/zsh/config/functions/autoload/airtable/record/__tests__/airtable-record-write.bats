bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned record ID
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo 'recNEW'
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes base, table, record and fields to the JS module" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --record recABC --fields '{\"name\":\"Paris\"}'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *'bin/airtable-record-write.js DevRel Meetups {"name":"Paris"} recABC' ]]
}

@test "passes an empty record when --record is not given" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --fields '{\"name\":\"Paris\"}'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *'bin/airtable-record-write.js DevRel Meetups {"name":"Paris"} ' ]]
}

@test "prints the record ID of the JS module" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --fields '{\"name\":\"Paris\"}'"
  [[ "$output" == "recNEW" ]]
}

@test "fails with a usage error when --fields is missing" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--fields"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "fails before any request when --fields is not valid JSON" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --fields '{name:'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--fields"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "fails before any request when --fields is not a JSON object" {
  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --fields '[1,2]'"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "exits non-zero and prints the message when the JS module fails" {
  node() {
    echo "Unknown field name" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-record-write --base DevRel --table Meetups --fields '{\"nope\":1}'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Unknown field name"* ]]
}
