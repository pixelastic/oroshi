bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. `gh pr view` prints the content of
  # gh-response, which holds both the merge state read by the gate and the
  # state of the pull request after the merge
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    [[ "$1 $2" == "pr view" ]] && cat "$BATS_TMP_DIR/gh-response"
    return 0
  }
  bats_mock git-directory-is-github gh

  set_response CLEAN MERGED null
}

# Set the gh response: the merge state, the state of the pull request and its
# auto-merge request
set_response() {
  jq --null-input \
    --arg mergeState "$1" \
    --arg state "$2" \
    --argjson autoMerge "$3" \
    '{number: 42, mergeStateStatus: $mergeState, state: $state, autoMergeRequest: $autoMerge}' \
    > "$BATS_TMP_DIR/gh-response"
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "rebases by default" {
  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge 42 --rebase"* ]]
}

@test "merges with --merge" {
  bats_run_zsh "git-pullrequest-accept 42 --merge"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge 42 --merge"* ]]
  [[ "$(gh_args)" != *"--rebase"* ]]
}

@test "squashes with --squash" {
  bats_run_zsh "git-pullrequest-accept 42 --squash"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge 42 --squash"* ]]
  [[ "$(gh_args)" != *"--rebase"* ]]
}

@test "stops when --merge and --squash are both given" {
  bats_run_zsh "git-pullrequest-accept 42 --merge --squash"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--merge"*"--squash"* ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "skips the gate with --force" {
  set_response BLOCKED MERGED null

  bats_run_zsh "git-pullrequest-accept 42 --force"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge 42 --rebase"* ]]
}

@test "never passes --admin to gh" {
  bats_run_zsh "git-pullrequest-accept 42 --force"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge"* ]]
  [[ "$(gh_args)" != *"--admin"* ]]
}

@test "stops without merging when the gate fails" {
  set_response BLOCKED OPEN null

  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"blocked"* ]]
  [[ "$(gh_args)" != *"pr merge"* ]]
}

@test "prints the id and the merged state" {
  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":42,"state":"merged"}' ]]
}

@test "prints the auto-merge state when gh enabled auto-merge" {
  set_response CLEAN OPEN '{"enabledBy": {"login": "tim"}}'

  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":42,"state":"auto-merge"}' ]]
}

@test "prints the queued state when gh queued the pull request" {
  set_response CLEAN OPEN null

  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":42,"state":"queued"}' ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-pullrequest-accept 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"pr merge 42"*"--repo pixelastic/imoen"* ]]
}

@test "fails when the merge fails" {
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    [[ "$1 $2" == "pr view" ]] && cat "$BATS_TMP_DIR/gh-response"
    [[ "$1 $2" == "pr merge" ]] && return 1
    return 0
  }
  bats_mock gh

  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-accept 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-accept 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
