bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  make-scenario-module-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "3▮airtable:ActionSearchRecords▮528▮2▮1"
    echo "1▮gateway:CustomWebHook▮50▮0▮0"
  }
  bats_mock make-scenario-module-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "make-scenario-module-list 925 --days 15 --app airtable"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "925 --days 15 --app airtable" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "make-scenario-module-list 925 --days 15 | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "3  airtable:ActionSearchRecords  528  2  1" ]]
  [[ "${lines[1]}" == "1  gateway:CustomWebHook         50   0  0" ]]
}

@test "colors only the module ID" {
  bats_run_zsh "make-scenario-module-list 925 --days 15"
  [[ "${lines[0]}" == $'\e['*"3"*$'\e[0m  airtable'* ]]
}

@test "prints nothing and exits non-zero without modules" {
  make-scenario-module-list-raw() {
    echo ""
  }
  bats_mock make-scenario-module-list-raw

  bats_run_zsh "make-scenario-module-list 925 --days 15 --app nothing"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  make-scenario-module-list-raw() {
    echo "MAKE_DAYS_OUT_OF_RANGE" >&2
    return 1
  }
  bats_mock make-scenario-module-list-raw

  bats_run_zsh "make-scenario-module-list 925 --days 99"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"MAKE_DAYS_OUT_OF_RANGE"* ]]
}
