bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  circleci-run-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "runA▮gh/o/r▮ci▮failed▮main▮abc1234▮2113▮2026-11-01▮85▮https://x.io/A"
    echo "runB▮gh/o/r▮ci▮running▮main▮def5678▮2114▮2026-11-02▮▮"
  }
  bats_mock circleci-run-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "circleci-run-list --project gh/o/r --status failed"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--project gh/o/r --status failed" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "circleci-run-list --project gh/o/r | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "runA  gh/o/r  ci  failed   main  abc1234  2113  2026-11-01  85  https://x.io/A" ]]
  [[ "${lines[1]}" == "runB  gh/o/r  ci  running  main  def5678  2114  2026-11-02" ]]
}

@test "colors only the run id" {
  bats_run_zsh "circleci-run-list --project gh/o/r"
  [[ "${lines[0]}" == $'\e['*"runA"*$'\e[0m'*"gh/o/r"* ]]
}

@test "prints nothing and exits non-zero without runs" {
  circleci-run-list-raw() {
    echo ""
  }
  bats_mock circleci-run-list-raw

  bats_run_zsh "circleci-run-list --project gh/o/r"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  circleci-run-list-raw() {
    echo "CIRCLECI_MISSING_ARGUMENT" >&2
    return 1
  }
  bats_mock circleci-run-list-raw

  bats_run_zsh "circleci-run-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"CIRCLECI_MISSING_ARGUMENT"* ]]
}
