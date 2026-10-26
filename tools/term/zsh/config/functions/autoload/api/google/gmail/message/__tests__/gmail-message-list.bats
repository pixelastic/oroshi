bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  gmail-message-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "msgA▮2026-03-12T10:05:00.000Z▮3▮Alice▯Bob▮Hello▮Hi there▮true"
    echo "msgB▮2026-03-11T08:00:00.000Z▮1▮Carol▮Lunch▮Noon?▮false"
  }
  bats_mock gmail-message-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
  bats_mock_env "TZ" "UTC"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "gmail-message-list --limit 10 --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --account perso" ]]
}

@test "shows one row per Message, with marker, date, count, authors and subject" {
  bats_run_zsh "gmail-message-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "●  03/12 10:05  3  Alice, Bob  Hello" ]]
  [[ "${lines[1]}" == "   03/11 08:00     Carol       Lunch" ]]
}

@test "colors the date, the count, the authors and the subject" {
  bats_run_zsh "gmail-message-list"
  [[ "${lines[0]}" == *$'\e['*"03/12 10:05"*$'\e[0m'*$'\e['*"3"*$'\e[0m'*$'\e['*"Alice, Bob"*$'\e[0m'*$'\e['*"Hello"*$'\e[0m' ]]
}

@test "prints nothing and exits non-zero for an empty inbox" {
  gmail-message-list-raw() {
    echo ""
  }
  bats_mock gmail-message-list-raw

  bats_run_zsh "gmail-message-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  gmail-message-list-raw() {
    echo "Token expired" >&2
    return 1
  }
  bats_mock gmail-message-list-raw

  bats_run_zsh "gmail-message-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Token expired"* ]]
}

@test "truncates long authors so the subject keeps its room" {
  gmail-message-list-raw() {
    echo "msgA▮2026-03-12T10:05:00.000Z▮2▮Alexandria Ocasio-Cortez▯Bartholomew Featherstonehaugh▮Hello▮Hi▮false"
  }
  bats_mock gmail-message-list-raw

  bats_run_zsh "gmail-message-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "   03/12 10:05  2  Alexandria Ocasio-Cortez, B…  Hello" ]]
}

@test "right-aligns the mail count" {
  gmail-message-list-raw() {
    echo "msgA▮2026-03-12T10:05:00.000Z▮12▮Alice▮Hello▮Hi▮false"
    echo "msgB▮2026-03-11T08:00:00.000Z▮3▮Carol▮Lunch▮Noon?▮false"
  }
  bats_mock gmail-message-list-raw

  bats_run_zsh "gmail-message-list | text-ansi-remove"
  [[ "${lines[0]}" == "   03/12 10:05  12  Alice  Hello" ]]
  [[ "${lines[1]}" == "   03/11 08:00   3  Carol  Lunch" ]]
}

@test "shows a blank date instead of failing on an invalid date" {
  gmail-message-list-raw() {
    echo "msgA▮▮1▮Alice▮Hello▮Hi▮false"
    echo "msgB▮2026-03-11T08:00:00.000Z▮1▮Carol▮Lunch▮Noon?▮false"
  }
  bats_mock gmail-message-list-raw

  bats_run_zsh "gmail-message-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == *"Alice"*"Hello" ]]
  [[ "${lines[1]}" == "   03/11 08:00     Carol  Lunch" ]]
}
