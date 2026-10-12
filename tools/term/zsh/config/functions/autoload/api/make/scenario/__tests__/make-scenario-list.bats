bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  make-scenario-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "925▮Sync▮true▮12▮2026-02-26T13:17:47.779Z"
    echo "926▮Backup▮false▮▮"
  }
  bats_mock make-scenario-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "make-scenario-list sync --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "sync --limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "make-scenario-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "925  Sync    true   12  2026-02-26T13:17:47.779Z" ]]
  [[ "${lines[1]}" == "926  Backup  false" ]]
}

@test "colors only the Scenario ID" {
  bats_run_zsh "make-scenario-list"
  [[ "${lines[0]}" == $'\e['*"925"*$'\e[0m  Sync'* ]]
}

@test "prints nothing and exits non-zero without Scenarios" {
  make-scenario-list-raw() {
    echo ""
  }
  bats_mock make-scenario-list-raw

  bats_run_zsh "make-scenario-list nothing"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  make-scenario-list-raw() {
    echo "MAKE_CREDENTIALS_MISSING" >&2
    return 1
  }
  bats_mock make-scenario-list-raw

  bats_run_zsh "make-scenario-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"MAKE_CREDENTIALS_MISSING"* ]]
}
