bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. `gh issue view` prints the content
  # of gh-response, the issue as it is after the reopen. `gh issue reopen`
  # fails when the gh-missing file exists, like an issue that does not exist
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    [[ -f "$BATS_TMP_DIR/gh-missing" ]] && return 1
    [[ "$1 $2" == "issue view" ]] && cat "$BATS_TMP_DIR/gh-response"
    return 0
  }
  bats_mock git-directory-is-github gh

  echo '{"number": 42, "state": "OPEN"}' > "$BATS_TMP_DIR/gh-response"
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "reopens the issue" {
  bats_run_zsh "git-issue-reopen 42"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue reopen 42"* ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-issue-reopen 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"issue reopen 42"*"--repo pixelastic/imoen"* ]]
}

@test "prints the id and the open state" {
  bats_run_zsh "git-issue-reopen 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":42,"state":"open"}' ]]
}

@test "fails when the issue does not exist" {
  touch "$BATS_TMP_DIR/gh-missing"

  bats_run_zsh "git-issue-reopen 999"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-reopen 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-reopen 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
