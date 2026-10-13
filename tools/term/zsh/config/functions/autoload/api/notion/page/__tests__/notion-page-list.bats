bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  notion-page-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "subA▮Paris Meetup"
    echo "subB▮Lyon"
  }
  bats_mock notion-page-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "notion-page-list pageA --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "pageA --limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "notion-page-list pageA | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "subA  Paris Meetup" ]]
  [[ "${lines[1]}" == "subB  Lyon" ]]
}

@test "colors only the Page ID" {
  bats_run_zsh "notion-page-list pageA"
  [[ "${lines[0]}" == $'\e['*"subA"*$'\e[0m  Paris Meetup' ]]
}

@test "prints nothing and exits non-zero for a Page without sub-pages" {
  notion-page-list-raw() {
    echo ""
  }
  bats_mock notion-page-list-raw

  bats_run_zsh "notion-page-list pageA"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  notion-page-list-raw() {
    echo "NOTION_ID_INVALID" >&2
    return 1
  }
  bats_mock notion-page-list-raw

  bats_run_zsh "notion-page-list pageA"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"NOTION_ID_INVALID"* ]]
}
