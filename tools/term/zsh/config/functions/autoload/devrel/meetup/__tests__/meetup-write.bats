bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the record write to log its arguments and the call order, then print a canned record ID
  airtable-record-write() {
    print -r -- "$@" >"$BATS_TMP_DIR/write-args"
    echo "write" >>"$BATS_TMP_DIR/calls"
    echo "recNEW"
  }
  # Stub the attachment add to log its arguments and the call order
  airtable-attachment-add() {
    print -r -- "$@" >"$BATS_TMP_DIR/attachment-args"
    echo "attachment" >>"$BATS_TMP_DIR/calls"
    echo "attNEW"
  }
  bats_mock airtable-record-write airtable-attachment-add
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "AIRTABLE_BASE_DEVREL" "appDEV"
}

# Reads the --fields JSON the record write received
written_fields() {
  local args="$(cat "$BATS_TMP_DIR/write-args")"
  echo "${args#*--fields }"
}

# Asserts that jq -r <path> on the --fields JSON the record write received equals <expected>
expect_field() {
  local jqPath="$1"
  local expected="$2"
  local actual="$(written_fields | jq -r "$jqPath")"

  [[ "$actual" == "$expected" ]] && return 0

  echo "expect_field $jqPath: expected '$expected', got '$actual'"
  return 1
}

@test "creates a pending meetup from the name alone" {
  bats_run_zsh "meetup-write --name 'Datadog User Group Paris'"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/write-args")" == "--base appDEV --table Meetups --fields "* ]]
  expect_field '.name' 'Datadog User Group Paris'
  expect_field '.status' '⏳️ Pending'
}

@test "prints the record ID" {
  bats_run_zsh "meetup-write --name 'Datadog User Group Paris'"
  [[ "$output" == "recNEW" ]]
}

@test "stores each optional flag in its Field" {
  bats_run_zsh "meetup-write --name Paris --url https://example.com --date 2026-12-01 --notes 'Bring slides'"
  [[ "$status" -eq 0 ]]
  expect_field '.URL' 'https://example.com'
  expect_field '.date' '2026-12-01'
  expect_field '.notes' 'Bring slides'
}

@test "leaves out the Fields of the flags not given" {
  bats_run_zsh "meetup-write --name Paris"
  expect_field 'keys | join(",")' 'name,status'
}

@test "keeps quotes in the notes" {
  bats_run_zsh "meetup-write --name Paris --notes 'Say \"hi\"'"
  expect_field '.notes' 'Say "hi"'
}

@test "stores the confirmed label for --status confirmed" {
  bats_run_zsh "meetup-write --name Paris --status confirmed"
  expect_field '.status' '✅ Confirmed'
}

@test "stores the cancelled label for --status cancelled" {
  bats_run_zsh "meetup-write --name Paris --status cancelled"
  expect_field '.status' '🛑 Cancelled'
}

@test "fails before any request on an unknown status" {
  bats_run_zsh "meetup-write --name Paris --status maybe"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Unknown status: maybe"* ]]
  [[ ! -e "$BATS_TMP_DIR/calls" ]]
}

@test "fails with a usage error when --name is missing" {
  bats_run_zsh "meetup-write --date 2026-12-01"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage: meetup-write"* ]]
  [[ ! -e "$BATS_TMP_DIR/calls" ]]
}

@test "exits non-zero when AIRTABLE_BASE_DEVREL is not set" {
  bats_mock_env "AIRTABLE_BASE_DEVREL" ""

  bats_run_zsh "meetup-write --name Paris"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_BASE_DEVREL"* ]]
  [[ ! -e "$BATS_TMP_DIR/calls" ]]
}

@test "adds no Attachment without --image" {
  bats_run_zsh "meetup-write --name Paris"
  [[ ! -e "$BATS_TMP_DIR/attachment-args" ]]
}

@test "adds the image to the Record once it exists" {
  bats_run_zsh "meetup-write --name Paris --image ./logo.png"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/attachment-args")" == "--base appDEV --record recNEW --field image --file ./logo.png" ]]
  [[ "$(cat "$BATS_TMP_DIR/calls")" == $'write\nattachment' ]]
}

@test "prints the record ID before the image step" {
  airtable-attachment-add() {
    echo "uploading"
  }
  bats_mock airtable-attachment-add

  bats_run_zsh "meetup-write --name Paris --image ./logo.png"
  [[ "${lines[0]}" == "recNEW" ]]
}

@test "keeps the Record and reports the error when the image upload fails" {
  airtable-attachment-add() {
    echo "File too large" >&2
    return 1
  }
  bats_mock airtable-attachment-add

  bats_run_zsh "meetup-write --name Paris --image ./logo.png"
  [[ "$status" -ne 0 ]]
  [[ "${lines[0]}" == "recNEW" ]]
  [[ "$output" == *"File too large"* ]]
  [[ "$output" == *"recNEW"*"image"* ]]
}

@test "exits non-zero when the record write fails" {
  airtable-record-write() {
    echo "Invalid token" >&2
    return 1
  }
  bats_mock airtable-record-write

  bats_run_zsh "meetup-write --name Paris --image ./logo.png"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid token"* ]]
  [[ ! -e "$BATS_TMP_DIR/attachment-args" ]]
}
