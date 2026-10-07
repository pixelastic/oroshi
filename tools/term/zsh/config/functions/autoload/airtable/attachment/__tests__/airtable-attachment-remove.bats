bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub node to record its arguments
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the location and one Attachment ID to the JS module" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo --attachment attONE"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-attachment-remove.js appXXX Meetups recABC Logo attONE" ]]
}

@test "passes every Attachment ID to the JS module" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo --attachment attONE --attachment attTWO"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-attachment-remove.js appXXX Meetups recABC Logo attONE attTWO" ]]
}

@test "passes --all to the JS module" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo --all"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-attachment-remove.js appXXX Meetups recABC Logo --all" ]]
}

@test "fails with a usage error when a location flag is missing" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --all"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--field"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "fails when neither --attachment nor --all is given" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--attachment"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "fails when both --attachment and --all are given" {
  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo --attachment attONE --all"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--all"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "exits non-zero and prints the message when the JS module fails" {
  node() {
    echo "Attachment not in Field Logo: attNOPE" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-attachment-remove --base appXXX --table Meetups --record recABC --field Logo --attachment attNOPE"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Attachment not in Field"* ]]
}
