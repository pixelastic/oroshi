bats_load_library 'helper'

setup() {
  bats_tmp_dir

  DRAFT_DIR="$BATS_TMP_DIR/claude/meetup-announce/recABC123"
  mkdir -p "$DRAFT_DIR/assets"

  # state.json — resolve-draft-dir would normally create this
  echo '{"meetupId":"recABC123","meetupName":"Paris Meetup","messages":{}}' > "$DRAFT_DIR/state.json"

  # Export vars needed by mock functions in the zsh subprocess
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"
  bats_mock_env DRAFT_DIR "$DRAFT_DIR"

  # Mock all __lib/ collaborators
  fetch-meetup() {
    echo '{"UUID":"abc-123","name":"Paris Meetup","date":"2026-09-15","startTime":"19:00","endTime":"22:00","description":"A great meetup","URL":"https://example.com","notes":"Some notes","helpersFullName":["Alice","Bob"],"guestRegisteredCount":42,"guestAttendingCountFinal":35}'
  }

  resolve-draft-dir() { echo "$DRAFT_DIR"; }

  download-assets() { return 0; }

  compute-schedule() {
    echo '{"window":"early","messages":[{"id":"early--office-paris--initial","scheduledFor":"2026-09-12T10:17","channel":"#office-paris"}]}'
  }

  kitty-window-create() { return 0; }

  bats_mock fetch-meetup resolve-draft-dir download-assets compute-schedule kitty-window-create
}

# -- Happy path --

@test "returns valid JSON with draftDir, window, meetup, and messages fields" {
  bats_run_zsh "meetup-announce-start recABC123"
  [[ "$status" -eq 0 ]]
  expect_json '.draftDir' "$DRAFT_DIR"
  expect_json '.window' 'early'
  expect_json '.meetup.name' 'Paris Meetup'
  expect_json '.messages | length' '1'
}

@test "messages array matches compute-schedule output" {
  bats_run_zsh "meetup-announce-start recABC123"
  [[ "$status" -eq 0 ]]
  expect_json '.messages[0].id' 'early--office-paris--initial'
  expect_json '.messages[0].scheduledFor' '2026-09-12T10:17'
  expect_json '.messages[0].channel' '#office-paris'
}

# -- Integration --

@test "draft directory exists after execution with assets/ subdirectory" {
  bats_run_zsh "meetup-announce-start recABC123"
  [[ "$status" -eq 0 ]]
  [[ -d "$DRAFT_DIR" ]]
  [[ -d "$DRAFT_DIR/assets" ]]
}

@test "state.json exists in draft directory" {
  bats_run_zsh "meetup-announce-start recABC123"
  [[ "$status" -eq 0 ]]
  [[ -f "$DRAFT_DIR/state.json" ]]
}

# -- Escaped newlines in meetup data --

@test "parses meetup fields correctly when description contains escaped newlines" {
  # print -r avoids ZSH echo interpreting \n — mimics real Airtable JSON with newlines in text fields
  fetch-meetup() {
    print -r -- '{"UUID":"abc-123","name":"Paris Meetup","date":"2026-09-15","startTime":"19:00","endTime":"22:00","description":"Line one\nLine two\nLine three","URL":"https://example.com","notes":"Note\nwith newlines","helpersFullName":["Alice"],"guestRegisteredCount":42,"guestAttendingCountFinal":35}'
  }
  bats_mock fetch-meetup

  bats_run_zsh "meetup-announce-start recABC123"
  [[ "$status" -eq 0 ]]
  expect_json '.meetup.name' 'Paris Meetup'
  expect_json '.meetup.date' '2026-09-15'
}

# -- Error handling --

@test "exits non-zero when recordId is missing" {
  bats_run_zsh "meetup-announce-start"
  [[ "$status" -ne 0 ]]
}

@test "exits non-zero when fetch-meetup fails" {
  fetch-meetup() { return 1; }
  bats_mock fetch-meetup

  bats_run_zsh "meetup-announce-start recBAD"
  [[ "$status" -ne 0 ]]
}
