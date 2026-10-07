bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned raw list
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo "tblABC▮Meetups"
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the Base to the JS module" {
  bats_run_zsh "airtable-table-list-raw --base appXXX"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-table-list-raw.js appXXX" ]]
}

@test "prints the lines of the JS module" {
  bats_run_zsh "airtable-table-list-raw --base appXXX"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "tblABC▮Meetups" ]]
}

@test "fails with a usage error when --base is missing" {
  bats_run_zsh "airtable-table-list-raw"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--base"* ]]
  [[ ! -f "$BATS_TMP_DIR/node-args" ]]
}

@test "prints nothing and exits zero for a Base without Tables" {
  node() {
    return 0
  }
  bats_mock node

  bats_run_zsh "airtable-table-list-raw --base appXXX"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the JS module fails" {
  node() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-table-list-raw --base appXXX"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
