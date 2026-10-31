bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  gcal-event-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "a▮Stand-up▮confirmed▮2026-11-02T10:00:00+01:00▮2026-11-02T10:15:00+01:00▮false▮3▮Room 1"
    echo "b▮Day off▮confirmed▮2026-11-03▮2026-11-03▮true▮0▮"
  }
  # A wide terminal, so that `table` does not truncate the rows
  terminal-width() { REPLY=200; }
  bats_mock gcal-event-list-raw terminal-width
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "gcal-event-list --week --calendarId work --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--week --calendarId work --account perso" ]]
}

@test "shows one row per Event, without the id, with aligned columns" {
  bats_run_zsh "gcal-event-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == *"Stand-up"* ]]
  [[ "${lines[0]}" != *"a▮"* ]]
  [[ "${lines[0]}" == "2026-11-02T10:00:00+01:00  2026-11-02T10:15:00+01:00           Stand-up  confirmed  3  Room 1" ]]
}

@test "marks an All-day Event" {
  bats_run_zsh "gcal-event-list | text-ansi-remove"
  [[ "${lines[0]}" != *"all-day"* ]]
  [[ "${lines[1]}" == *"all-day"* ]]
}

@test "colors the title" {
  bats_run_zsh "gcal-event-list"
  [[ "${lines[0]}" == *$'\e['*"Stand-up"*$'\e[0m'* ]]
}

@test "prints nothing and exits non-zero when there is no Event" {
  gcal-event-list-raw() {
    echo ""
  }
  bats_mock gcal-event-list-raw

  bats_run_zsh "gcal-event-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
