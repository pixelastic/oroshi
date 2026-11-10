bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call and prints the URL of the comment
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    echo "https://github.com/pixelastic/imoen/issues/42#issuecomment-987654"
    return 0
  }
  bats_mock git-directory-is-github gh
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "comments on an issue with --issueId" {
  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue comment 42 --body Thanks" ]]
}

@test "comments on a pull request with --pullrequestId" {
  bats_run_zsh "git-comment-create --pullrequestId 108 --body 'Thanks'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "pr comment 108 --body Thanks" ]]
}

@test "passes the body text" {
  bats_run_zsh "git-comment-create --issueId 42 --body 'Looks good to me'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--body Looks good to me"* ]]
}

@test "passes the content of the body file" {
  echo "From a file" > "$BATS_TMP_DIR/body.md"

  bats_run_zsh "git-comment-create --issueId 42 --body-file '$BATS_TMP_DIR/body.md'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--body From a file"* ]]
}

@test "fails when no body is given" {
  bats_run_zsh "git-comment-create --issueId 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "fails when the body is empty" {
  bats_run_zsh "git-comment-create --issueId 42 --body ''"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "fails when the target is ambiguous" {
  bats_run_zsh "git-comment-create --issueId 42 --pullrequestId 108 --body 'Thanks'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "fails when no target is given" {
  bats_run_zsh "git-comment-create --body 'Thanks'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks' --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue comment 42 --body Thanks --repo pixelastic/imoen" ]]
}

@test "prints the comment id and url" {
  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":987654,"url":"https://github.com/pixelastic/imoen/issues/42#issuecomment-987654"}' ]]
}

@test "prints the comment id of a pull request comment" {
  gh() { echo "https://github.com/pixelastic/imoen/pull/108#issuecomment-555"; }
  bats_mock gh

  bats_run_zsh "git-comment-create --pullrequestId 108 --body 'Thanks'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.id' <<< "$output")" == "555" ]]
}

@test "fails when gh fails" {
  gh() { return 1; }
  bats_mock gh

  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-comment-create --issueId 42 --body 'Thanks' --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
