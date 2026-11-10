bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call and prints nothing, like GitHub does
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    return 0
  }
  bats_mock git-directory-is-github gh
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "deletes the comment" {
  bats_run_zsh "git-comment-delete 987654"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/{owner}/{repo}/issues/comments/987654 --method DELETE' ]]
}

@test "prints the deleted id" {
  bats_run_zsh "git-comment-delete 987654"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":987654}' ]]
}

@test "shows the error when GitHub refuses" {
  gh() {
    echo "gh: Forbidden (HTTP 403)" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-comment-delete 987654"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"HTTP 403"* ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-comment-delete 987654 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/pixelastic/imoen/issues/comments/987654 --method DELETE' ]]
}

@test "fails when no comment id is given" {
  bats_run_zsh "git-comment-delete"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}
