bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  gcal-calendar-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "me@example.com▮Me▮true▮Europe/Paris"
    echo "work@example.com▮Work▮false▮Europe/London"
  }
  bats_mock gcal-calendar-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "gcal-calendar-list --limit 10 --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --account perso" ]]
}

@test "shows one row per Calendar, with aligned columns" {
  bats_run_zsh "gcal-calendar-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "me@example.com    Me    primary  Europe/Paris" ]]
  [[ "${lines[1]}" == "work@example.com  Work           Europe/London" ]]
}

@test "colors the id" {
  bats_run_zsh "gcal-calendar-list"
  [[ "${lines[0]}" == *$'\e['*"me@example.com"*$'\e[0m'* ]]
}

@test "prints nothing and exits non-zero when there is no Calendar" {
  gcal-calendar-list-raw() {
    echo ""
  }
  bats_mock gcal-calendar-list-raw

  bats_run_zsh "gcal-calendar-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
