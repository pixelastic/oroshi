bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. `gh issue view` prints the content
  # of gh-response, the issue as it is after the edit
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    [[ "$1 $2" == "issue view" ]] && cat "$BATS_TMP_DIR/gh-response"
    return 0
  }
  bats_mock git-directory-is-github gh

  echo '{"number": 42, "title": "New title", "url": "https://github.com/pixelastic/imoen/issues/42"}' > "$BATS_TMP_DIR/gh-response"
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "passes --title to gh issue edit" {
  bats_run_zsh "git-issue-update 42 --title 'New title'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue edit 42"*"--title New title"* ]]
}

@test "passes the body text to gh issue edit" {
  bats_run_zsh "git-issue-update 42 --body 'New body'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue edit 42"*"--body New body"* ]]
}

@test "passes the content of the body file to gh issue edit" {
  printf 'From file\n' > "$BATS_TMP_DIR/body.md"

  bats_run_zsh "git-issue-update 42 --body-file '$BATS_TMP_DIR/body.md'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue edit 42"*"--body From file"* ]]
}

@test "fails when --body and --body-file are both given" {
  printf 'From file' > "$BATS_TMP_DIR/body.md"

  bats_run_zsh "git-issue-update 42 --body 'From flag' --body-file '$BATS_TMP_DIR/body.md'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "fails when no flag is given" {
  bats_run_zsh "git-issue-update 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-issue-update 42 --title 'New title' --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue edit 42"*"--repo pixelastic/imoen"* ]]
}

@test "prints the id, title and url of the issue" {
  bats_run_zsh "git-issue-update 42 --title 'New title'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":42,"title":"New title","url":"https://github.com/pixelastic/imoen/issues/42"}' ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-update 42 --title 'New title'"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-update 42 --title 'New title' --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
