bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  confluence-page-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "111▮Paris meetup▮Engineering▮https://a.net/ENG/111"
    echo "222▮Notes▮Design▮https://a.net/DES/222"
  }
  bats_mock confluence-page-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the query and the flags to the raw list as received" {
  bats_run_zsh "confluence-page-list meetup --limit 10 --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "meetup --limit 10 --account perso" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "confluence-page-list meetup | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "111  Paris meetup  Engineering  https://a.net/ENG/111" ]]
  [[ "${lines[1]}" == "222  Notes         Design       https://a.net/DES/222" ]]
}

@test "colors only the page id" {
  bats_run_zsh "confluence-page-list meetup"
  [[ "${lines[0]}" == $'\e['*"111"*$'\e[0m  Paris meetup  Engineering  '* ]]
}

@test "prints nothing and exits non-zero when no page matches" {
  confluence-page-list-raw() {
    echo ""
  }
  bats_mock confluence-page-list-raw

  bats_run_zsh "confluence-page-list meetup"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  confluence-page-list-raw() {
    echo "CONFLUENCE_TOKEN is not set" >&2
    return 1
  }
  bats_mock confluence-page-list-raw

  bats_run_zsh "confluence-page-list meetup"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"CONFLUENCE_TOKEN is not set"* ]]
}
