bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  airtable-base-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "appABC▮DevRel"
    echo "appDEF▮Other Base"
  }
  bats_mock airtable-base-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "airtable-base-list --limit 10 --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10 --account perso" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "airtable-base-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "appABC  DevRel" ]]
  [[ "${lines[1]}" == "appDEF  Other Base" ]]
}

@test "colors only the Base ID" {
  bats_run_zsh "airtable-base-list"
  [[ "${lines[0]}" == $'\e['*"appABC"*$'\e[0m  DevRel' ]]
}

@test "prints nothing and exits non-zero when no Base is accessible" {
  airtable-base-list-raw() {
    echo ""
  }
  bats_mock airtable-base-list-raw

  bats_run_zsh "airtable-base-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  airtable-base-list-raw() {
    echo "AIRTABLE_TOKEN is not set" >&2
    return 1
  }
  bats_mock airtable-base-list-raw

  bats_run_zsh "airtable-base-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"AIRTABLE_TOKEN is not set"* ]]
}
