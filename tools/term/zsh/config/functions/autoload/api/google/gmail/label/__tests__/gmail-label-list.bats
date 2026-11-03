bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Stub the raw list to record its arguments, then print canned lines
  gmail-label-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "Label_1▮Work▮user▮#16a766▮#ffffff"
    echo "Label_22▮Home▮user▮▮"
  }
  bats_mock gmail-label-list-raw
  bats_mock_env "BATS_TMP_DIR" "$BATS_TMP_DIR"
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "gmail-label-list work --account perso"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "work --account perso" ]]
}

@test "shows one row per label, with aligned columns" {
  bats_run_zsh "gmail-label-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "Label_1   Work  user  #16a766  #ffffff" ]]
  [[ "${lines[1]}" == "Label_22  Home  user" ]]
}

@test "colors the id" {
  bats_run_zsh "gmail-label-list"
  [[ "${lines[0]}" == *$'\e['*"Label_1"*$'\e[0m'* ]]
}

@test "colors the name with the hexadecimal color of the label, in true color" {
  bats_run_zsh "gmail-label-list"
  [[ "${lines[0]}" == *$'\e[38;2;22;167;102m'"Work"$'\e[0m'* ]]
}

@test "leaves the name of a label without color uncolored" {
  bats_run_zsh "gmail-label-list"
  [[ "${lines[1]}" != *$'\e[38;2;'* ]]
  [[ "${lines[1]}" == *"Home"* ]]
}

@test "prints nothing and exits non-zero for an empty listing" {
  gmail-label-list-raw() {
    echo ""
  }
  bats_mock gmail-label-list-raw

  bats_run_zsh "gmail-label-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "exits non-zero when the raw list fails" {
  gmail-label-list-raw() {
    echo "Token expired" >&2
    return 1
  }
  bats_mock gmail-label-list-raw

  bats_run_zsh "gmail-label-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Token expired"* ]]
}
