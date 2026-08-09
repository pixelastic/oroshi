bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"

  git-directory-is-github() { return 0; }
  gh() { echo "issue #1"; }
  git-issue-count() { echo "3"; }
  git-github-project() { echo "pixelastic/my-repo"; }
  bats_mock git-directory-is-github gh git-issue-count git-github-project
}

@test "writes issue count to OROSHI_TMP_FOLDER/github/<project>/issues" {
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
