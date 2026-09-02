bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export AIRTABLE_DEVREL_MEETUPS_TOKEN_READONLY="test-token-123"
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/ai/meetup-announce/__lib/fetch-meetup.zsh'"
  EXPECTED_FIELDS="UUID,name,date,startTime,endTime,description,URL,notes,helpersFullName,guestRegisteredCount,guestAttendingCountFinal,pictureMain,pictureLogo,pictureBackground,horizontalScreen,verticalScreen,signagePrint"
}

@test "returns JSON containing all expected fields" {
  airtable-record-read() {
    echo '{"UUID":"abc-123","name":"Paris Meetup","date":"2026-09-15","startTime":"19:00","endTime":"22:00","description":"A great meetup","URL":"https://example.com","notes":"Some notes","helpersFullName":["Alice","Bob"],"guestRegisteredCount":42,"guestAttendingCountFinal":35,"pictureMain":"https://img/main.jpg","pictureLogo":"https://img/logo.jpg","pictureBackground":"https://img/bg.jpg","horizontalScreen":"https://img/h.jpg","verticalScreen":"https://img/v.jpg","signagePrint":"https://img/s.jpg"}'
  }
  bats_mock airtable-record-read

  bats_run_zsh "$sourcePrefix && fetch-meetup rec29mm4kHeaPDt0x"
  [[ "$status" -eq 0 ]]
  expect_json '.UUID' 'abc-123'
  expect_json '.name' 'Paris Meetup'
  expect_json '.date' '2026-09-15'
  expect_json '.startTime' '19:00'
  expect_json '.endTime' '22:00'
  expect_json '.description' 'A great meetup'
  expect_json '.URL' 'https://example.com'
  expect_json '.notes' 'Some notes'
  expect_json '.signagePrint' 'https://img/s.jpg'
}

@test "does not return fields outside the expected list" {
  # The field list passed to airtable-record-read controls what Airtable returns
  airtable-record-read() {
    echo "$@" > "$BATS_TMP_DIR/args.txt"
    echo '{}'
  }
  bats_mock airtable-record-read

  bats_run_zsh "$sourcePrefix && fetch-meetup recXXX"

  local args="$(cat "$BATS_TMP_DIR/args.txt")"
  [[ "$args" == *"--fields $EXPECTED_FIELDS"* ]]
}

@test "exits non-zero when airtable-record-read fails" {
  airtable-record-read() { return 1; }
  bats_mock airtable-record-read

  bats_run_zsh "$sourcePrefix && fetch-meetup recINVALID"
  [[ "$status" -ne 0 ]]
}
