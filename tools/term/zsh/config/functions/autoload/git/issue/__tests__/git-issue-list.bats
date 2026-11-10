bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_FOLDER_STATE "$BATS_TMP_DIR"
  bats_mock_env BATS_TMP_DIR "$BATS_TMP_DIR"

  # Stub the raw list to record its arguments, then print canned lines
  git-issue-list-raw() {
    print -r -- "$@" >"$BATS_TMP_DIR/raw-args"
    echo "42▮Login bug▮open▮2026-01-02T03:04:05Z▮tim▮x.io/42▮bug▯ui"
    echo "43▮Logout bug▮closed▮2026-01-03T03:04:05Z▮bot▮x.io/43▮"
  }
  git-directory-is-github() { return 0; }
  git-issue-count() { echo "3"; }
  git-github-project() { echo "pixelastic/my-repo"; }
  bats_mock git-issue-list-raw git-directory-is-github git-issue-count git-github-project
}

@test "passes the flags to the raw list as received" {
  bats_run_zsh "git-issue-list --state closed --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/raw-args")" == "--state closed --repo pixelastic/imoen" ]]
}

@test "prints a table with one row per issue" {
  bats_run_zsh "git-issue-list | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "42  Login bug   open    2026-01-02T03:04:05Z  tim  x.io/42  bug, ui" ]]
  [[ "${lines[1]}" == "43  Logout bug  closed  2026-01-03T03:04:05Z  bot  x.io/43" ]]
}

@test "colors only the id" {
  bats_run_zsh "git-issue-list"
  [[ "${lines[0]}" == $'\e['*"42"*$'\e[0m'*"Login bug"* ]]
}

@test "writes issue count to OROSHI_FOLDER_STATE/github/<project>/issues" {
  bats_run_zsh "git-issue-list"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/github/pixelastic/my-repo/issues" ]]
  [[ "$(cat "$BATS_TMP_DIR/github/pixelastic/my-repo/issues")" == "3" ]]
}

@test "creates parent directory if missing" {
  bats_run_zsh "git-issue-list"
  [[ "$status" -eq 0 ]]
  [[ -d "$BATS_TMP_DIR/github/pixelastic/my-repo" ]]
}

@test "leaves the cache alone with --repo" {
  bats_run_zsh "git-issue-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/github" ]]
}

@test "stops outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
  [[ ! -e "$BATS_TMP_DIR/raw-args" ]]
}

@test "lists another repo outside a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-list --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "prints nothing and exits non-zero without issues" {
  git-issue-list-raw() {
    echo ""
  }
  bats_mock git-issue-list-raw

  bats_run_zsh "git-issue-list"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}
