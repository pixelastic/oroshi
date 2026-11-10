bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"
  bats_mock_env BATS_TMP_DIR "$BATS_TMP_DIR"

  # Stub the raw list to record its arguments, then print canned lines
  git-pullrequest-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "27▮Add login▮open▮2026-01-02▮tim▮x.io/27▮bug▯ui▮feat▮main▮success"
    echo "28▮Fix logout▮merged▮2026-01-03▮bot▮x.io/28▮▮fix▮main▮"
  }
  git-directory-is-github() { return 0; }
  git-pullrequest-count() { echo "5"; }
  git-github-project() { echo "pixelastic/my-repo"; }
  bats_mock git-pullrequest-list-raw git-directory-is-github git-pullrequest-count git-github-project
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "git-pullrequest-list --state merged --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--state merged --repo pixelastic/imoen" ]]
}

@test "prints a table with one row per pull request" {
  bats_run_zsh "git-pullrequest-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "27  Add login   open    2026-01-02  tim  x.io/27  bug, ui  feat  main  success" ]]
  [[ "${lines[1]}" == "28  Fix logout  merged  2026-01-03  bot  x.io/28           fix   main" ]]
}

@test "colors only the id" {
  bats_run_zsh "git-pullrequest-list"
  [[ "${lines[0]}" == $'\e['*"27"*$'\e[0m'*"Add login"* ]]
}

@test "writes pull request count to OROSHI_FOLDER_STATE/github/<project>/pullrequests" {
  bats_run_zsh "git-pullrequest-list"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/github/pixelastic/my-repo/pullrequests" ]]
  [[ "$(cat "$BATS_TMP_DIR/github/pixelastic/my-repo/pullrequests")" == "5" ]]
}

@test "creates parent directory if missing" {
  bats_run_zsh "git-pullrequest-list"
  [[ "$status" -eq 0 ]]
  [[ -d "$BATS_TMP_DIR/github/pixelastic/my-repo" ]]
}

@test "leaves the cache alone with --repo" {
  bats_run_zsh "git-pullrequest-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/github" ]]
}

@test "stops outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/raw-args" ]]
}

@test "lists another repo outside a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "prints nothing and exits non-zero without pull requests" {
  git-pullrequest-list-raw() {
    echo ""
  }
  bats_mock git-pullrequest-list-raw

  bats_run_zsh "git-pullrequest-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
