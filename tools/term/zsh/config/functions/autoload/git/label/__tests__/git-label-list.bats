bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env BATS_TMP_DIR "$BATS_TMP_DIR"

  # Stub the raw list to record its arguments, then print canned lines
  git-label-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "bug▮#d73a4a▮Something is broken"
    echo "help wanted▮#008672▮"
  }
  git-directory-is-github() { return 0; }
  bats_mock git-label-list-raw git-directory-is-github
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "git-label-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--repo pixelastic/imoen" ]]
}

@test "renders the labels as a table" {
  bats_run_zsh "git-label-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bug          #d73a4a  Something is broken" ]]
  [[ "${lines[1]}" == "help wanted  #008672" ]]
}

@test "shows the color of each label" {
  bats_run_zsh "git-label-list"
  [[ "${lines[0]}" == *$'\e[38;2;215;58;74m'"bug"$'\e[0m'* ]]
  [[ "${lines[1]}" == *$'\e[38;2;0;134;114m'"help wanted"$'\e[0m'* ]]
}

@test "stops outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/raw-args" ]]
}

@test "lists another repo outside a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "prints nothing and exits non-zero without labels" {
  git-label-list-raw() {
    echo ""
  }
  bats_mock git-label-list-raw

  bats_run_zsh "git-label-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
