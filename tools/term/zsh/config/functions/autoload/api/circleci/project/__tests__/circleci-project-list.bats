bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  circleci-project-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "gh/pixelastic/firost▮main"
    echo "gh/pixelastic/golgoth▮"
  }
  bats_mock circleci-project-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "circleci-project-list firost --limit 5"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "firost --limit 5" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "circleci-project-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "gh/pixelastic/firost   main" ]]
  [[ "${lines[1]}" == "gh/pixelastic/golgoth" ]]
}

@test "colors only the project slug" {
  bats_run_zsh "circleci-project-list"
  [[ "${lines[0]}" == $'\e['*"gh/pixelastic/firost"*$'\e[0m   main' ]]
}

@test "prints nothing and exits non-zero without projects" {
  circleci-project-list-raw() {
    echo ""
  }
  bats_mock circleci-project-list-raw

  bats_run_zsh "circleci-project-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  circleci-project-list-raw() {
    echo "CIRCLECI_CREDENTIALS_MISSING" >&2
    return 1
  }
  bats_mock circleci-project-list-raw

  bats_run_zsh "circleci-project-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"CIRCLECI_CREDENTIALS_MISSING"* ]]
}
