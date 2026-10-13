bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  notion-database-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "rowA▮Paris Meetup"
    echo "rowB▮Lyon"
  }
  bats_mock notion-database-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "notion-database-list dbA --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "dbA --limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "notion-database-list dbA | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "rowA  Paris Meetup" ]]
  [[ "${lines[1]}" == "rowB  Lyon" ]]
}

@test "colors only the database row ID" {
  bats_run_zsh "notion-database-list dbA"
  [[ "${lines[0]}" == $'\e['*"rowA"*$'\e[0m  Paris Meetup' ]]
}

@test "prints nothing and exits non-zero for an empty database" {
  notion-database-list-raw() {
    echo ""
  }
  bats_mock notion-database-list-raw

  bats_run_zsh "notion-database-list dbA"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  notion-database-list-raw() {
    echo "NOTION_ID_INVALID" >&2
    return 1
  }
  bats_mock notion-database-list-raw

  bats_run_zsh "notion-database-list dbA"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"NOTION_ID_INVALID"* ]]
}
