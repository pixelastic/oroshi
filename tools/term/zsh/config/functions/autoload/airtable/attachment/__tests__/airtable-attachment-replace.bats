bats_load_library 'helper'

setup() {
  bats_tmp_dir
  echo "Hello world" >"$BATS_TMP_DIR/notes.txt"
  # Stub node to record its arguments, then print a canned Attachment ID
  node() {
    print -r -- "$@" >"$BATS_TMP_DIR/node-args"
    echo 'attNEW'
  }
  bats_mock node
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the location, file and content type to the JS module" {
  bats_run_zsh "airtable-attachment-replace --base appXXX --table Meetups --record recABC --field Logo --file $BATS_TMP_DIR/notes.txt"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args")" == *"bin/airtable-attachment-replace.js appXXX Meetups recABC Logo $BATS_TMP_DIR/notes.txt text/plain" ]]
}

@test "prints the Attachment ID of the JS module" {
  bats_run_zsh "airtable-attachment-replace --base appXXX --table Meetups --record recABC --field Logo --file $BATS_TMP_DIR/notes.txt"
  [[ "$output" == "attNEW" ]]
}

@test "fails with a usage error when a flag is missing" {
  bats_run_zsh "airtable-attachment-replace --base appXXX --table Meetups --record recABC --file $BATS_TMP_DIR/notes.txt"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--field"* ]]
  [[ ! -e "$BATS_TMP_DIR/node-args" ]]
}

@test "exits non-zero and prints the message when the JS module fails" {
  node() {
    echo "Upload failed" >&2
    return 1
  }
  bats_mock node

  bats_run_zsh "airtable-attachment-replace --base appXXX --table Meetups --record recABC --field Logo --file nope.png"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Upload failed"* ]]
}
