bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  make-execution-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "cfcf▮3▮auto▮2026-10-12T09:46:06.720Z▮190▮0"
    echo "7985▮▮stop▮2026-10-12T09:46:07.585Z▮▮"
  }
  bats_mock make-execution-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "make-execution-list --scenarioId 925 --status error"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--scenarioId 925 --status error" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "make-execution-list --scenarioId 925 | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "cfcf  3  auto  2026-10-12T09:46:06.720Z  190  0" ]]
  [[ "${lines[1]}" == "7985     stop  2026-10-12T09:46:07.585Z" ]]
}

@test "colors only the Execution ID" {
  bats_run_zsh "make-execution-list --scenarioId 925"
  [[ "${lines[0]}" == $'\e['*"cfcf"*$'\e[0m  3'* ]]
}

@test "prints nothing and exits non-zero without Executions" {
  make-execution-list-raw() {
    echo ""
  }
  bats_mock make-execution-list-raw

  bats_run_zsh "make-execution-list --scenarioId 925"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  make-execution-list-raw() {
    echo "MAKE_CREDENTIALS_MISSING" >&2
    return 1
  }
  bats_mock make-execution-list-raw

  bats_run_zsh "make-execution-list --scenarioId 925"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"MAKE_CREDENTIALS_MISSING"* ]]
}
