bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  make-folder-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "399268▮publishing▮publishing▮▮6"
    echo "539242▮child▮parent/child▮539241▮0"
  }
  bats_mock make-folder-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "make-folder-list --limit 10"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--limit 10" ]]
}

@test "shows the same rows as the raw list, with aligned columns" {
  bats_run_zsh "make-folder-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "399268  publishing  publishing            6" ]]
  [[ "${lines[1]}" == "539242  child       parent/child  539241  0" ]]
}

@test "colors only the Folder ID" {
  bats_run_zsh "make-folder-list"
  [[ "${lines[0]}" == $'\e['*"399268"*$'\e[0m  publishing'* ]]
}

@test "prints nothing and exits non-zero without Folders" {
  make-folder-list-raw() {
    echo ""
  }
  bats_mock make-folder-list-raw

  bats_run_zsh "make-folder-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  make-folder-list-raw() {
    echo "MAKE_CREDENTIALS_MISSING" >&2
    return 1
  }
  bats_mock make-folder-list-raw

  bats_run_zsh "make-folder-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"MAKE_CREDENTIALS_MISSING"* ]]
}
