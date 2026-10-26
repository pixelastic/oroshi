bats_load_library 'helper'

# Mock immediate collaborators; plan-directory returns a path in $BATS_TMP_DIR
_mock_defaults() {
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  git-branch-current() { echo "feature/my-feature"; }
  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/repo--feature_my-feature"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current plan-directory
}

setup() {
  bats_tmp_dir
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR"
}

@test "creates plan dir as git repo with initial commit, outputs JSON" {
  _mock_defaults
  local planDir="$MOCK_OROSHI_PLANS_DIR/repo--feature_my-feature"

  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]

  # Plan dir created as git repo
  [[ -d "$planDir" ]]
  git -C "$planDir" rev-parse --git-dir > /dev/null
  # Has exactly one commit
  [[ "$(git -C "$planDir" log --oneline | wc -l)" -eq 1 ]]

  # JSON output
  expect_json '.worktreePath' "$BATS_TMP_DIR"
  expect_json '.branch' 'feature/my-feature'
  expect_json '.planDir' "$planDir/"
  expect_json 'keys | length' '3'
}

@test "idempotent: second call does not re-init" {
  _mock_defaults
  local planDir="$MOCK_OROSHI_PLANS_DIR/repo--feature_my-feature"

  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]
  [[ -d "$planDir/.git" ]]
  local firstCommit="$(git -C "$planDir" rev-parse HEAD)"
  [[ "$firstCommit" != "" ]]

  # Re-mock for second call
  _mock_defaults
  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]

  # Same commit hash = no re-init
  [[ "$(git -C "$planDir" rev-parse HEAD)" == "$firstCommit" ]]
}

@test "exits 1 when not in worktree and no branch given" {
  git-directory-is-worktree() { return 1; }
  bats_mock git-directory-is-worktree

  bats_run_zsh "plan-start"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"branch name required"* ]]
}

@test "creates state.json with an empty issues array" {
  _mock_defaults
  local planDir="$MOCK_OROSHI_PLANS_DIR/repo--feature_my-feature"

  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]

  [[ "$(jq --compact-output '.issues' "$planDir/state.json")" == "[]" ]]
}

@test "does not overwrite an existing state.json" {
  _mock_defaults
  local planDir="$MOCK_OROSHI_PLANS_DIR/repo--feature_my-feature"
  mkdir -p "$planDir"
  echo '{"issues":[{"id":"01"}]}' > "$planDir/state.json"

  bats_run_zsh "plan-start"
  [[ "$status" -eq 0 ]]

  [[ "$(jq '.issues | length' "$planDir/state.json")" -eq 1 ]]
}
