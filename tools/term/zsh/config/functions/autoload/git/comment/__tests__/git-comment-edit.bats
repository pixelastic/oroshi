bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call and prints the REST comment
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    cat <<'JSON'
{"id":987654,"body":"New text","html_url":"https://github.com/pixelastic/imoen/issues/42#issuecomment-987654"}
JSON
    return 0
  }
  bats_mock git-directory-is-github gh
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "sends the body text" {
  bats_run_zsh "git-comment-edit 987654 --body 'New text'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/{owner}/{repo}/issues/comments/987654 --method PATCH --raw-field body=New text' ]]
}

@test "sends the content of the body file" {
  echo "From a file" > "$BATS_TMP_DIR/body.md"

  bats_run_zsh "git-comment-edit 987654 --body-file '$BATS_TMP_DIR/body.md'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--raw-field body=From a file"* ]]
}

@test "fails when no body is given" {
  bats_run_zsh "git-comment-edit 987654"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "prints the id and url" {
  bats_run_zsh "git-comment-edit 987654 --body 'New text'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":987654,"url":"https://github.com/pixelastic/imoen/issues/42#issuecomment-987654"}' ]]
}

@test "shows the error when GitHub refuses" {
  gh() {
    echo "gh: Must have admin rights to Repository. (HTTP 403)" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-comment-edit 987654 --body 'New text'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"HTTP 403"* ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-comment-edit 987654 --body 'New text' --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/pixelastic/imoen/issues/comments/987654 --method PATCH --raw-field body=New text' ]]
}

@test "fails when no comment id is given" {
  bats_run_zsh "git-comment-edit --body 'New text'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}
