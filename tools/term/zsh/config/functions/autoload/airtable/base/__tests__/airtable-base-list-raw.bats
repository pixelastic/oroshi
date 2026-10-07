bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments, then print a canned raw list
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo "appABC▮DevRel"
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "calls the JS module" {
  bats_run_zsh "airtable-base-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-base-list-raw.js" ]]
}

@test "prints the lines of the JS module" {
  bats_run_zsh "airtable-base-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "appABC▮DevRel" ]]
}

@test "prints nothing and exits zero when no Base is accessible" {
  node() {
    return 0
  }
  bats_mock node

  bats_run_zsh "airtable-base-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the JS module fails" {
  node() {
    echo "AIRTABLE_TOKEN_READ is not set" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-base-list-raw"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN_READ is not set"* ]]
}
