bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned result
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo '[{"id":"recA","fields":{"name":"Paris Meetup"}}]'
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes base, table, --in field, text, fields and limit to the JS module" {
  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name --fields name,date --limit 5 paris"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-search.js appXXX Meetups name paris name,date 5" ]]
}

@test "passes empty fields and limit when they are not given" {
  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name paris"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-search.js appXXX Meetups name paris  " ]]
}

@test "passes a text containing a quote unchanged" {
  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name \"it's\""
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-record-search.js appXXX Meetups name it's  " ]]
}

@test "prints the JSON of the JS module" {
  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name paris"
  expect_json '.[0].id' 'recA'
}

@test "prints an empty JSON array when nothing matches" {
  node() {
    echo '[]'
  }
  bats_mock node

  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name nothing"
  [[ "$status" -eq 0 ]]
  expect_json 'length' '0'
}

@test "exits non-zero when the JS module fails" {
  node() {
    echo "Invalid formula" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name paris"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid formula"* ]]
}

@test "prints a usage error when the search text is missing" {
  bats_run_zsh "airtable-record-search --base appXXX --table Meetups --in name"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
  [[ ! -f "$BATS_TMP_DIR/node-args" ]]
}
