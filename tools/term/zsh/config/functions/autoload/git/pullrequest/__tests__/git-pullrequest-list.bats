bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_TMP_FOLDER "$BATS_TMP_DIR"

  git-directory-is-github() { return 0; }
  gh() { echo "PR #1"; }
  git-pullrequest-count() { echo "5"; }
  git-github-project() { echo "pixelastic/my-repo"; }
  bats_mock git-directory-is-github gh git-pullrequest-count git-github-project
}

@test "writes PR count to OROSHI_TMP_FOLDER/github/<project>/pullrequests" {
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
