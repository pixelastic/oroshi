bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call
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

@test "detaches the label from an issue" {
  bats_run_zsh "git-label-detach bug --issueId 42"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue edit 42 --remove-label bug" ]]
}

@test "detaches the label from a pull request" {
  bats_run_zsh "git-label-detach 'help wanted' --pullrequestId 108"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "pr edit 108 --remove-label help wanted" ]]
}

@test "fails when the target is ambiguous" {
  bats_run_zsh "git-label-detach bug --issueId 42 --pullrequestId 108"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "fails when no target is given" {
  bats_run_zsh "git-label-detach bug"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "prints the label name and the issue" {
  bats_run_zsh "git-label-detach bug --issueId 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug","issueId":42}' ]]
}

@test "prints the label name and the pull request" {
  bats_run_zsh "git-label-detach bug --pullrequestId 108"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug","pullrequestId":108}' ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-label-detach bug --issueId 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue edit 42 --remove-label bug --repo pixelastic/imoen" ]]
}

@test "fails when gh fails" {
  gh() { return 1; }
  bats_mock gh

  bats_run_zsh "git-label-detach bug --issueId 42"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-detach bug --issueId 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-detach bug --issueId 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
