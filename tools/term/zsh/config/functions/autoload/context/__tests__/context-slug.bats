bats_load_library 'helper'

# Mock all collaborators — context-slug now delegates to context-raw
_mock_defaults() {
  context-raw() { REPLY="oroshi▮▮/repos/oroshi"; }
  git-branch-slug() { echo "yarn-sync"; }
  bats_mock context-raw git-branch-slug
}

setup() {
  bats_tmp_dir
}

@test "regular repo: returns project name" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi" ]]
}

@test "worktree: returns project--branchSlug" {
  _mock_defaults
  context-raw() { REPLY="oroshi▮feat/something▮/worktrees/oroshi--feat_something"; }
  git-branch-slug() { echo "feat_something"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi--feat_something" ]]
}

@test "submodule-in-worktree: returns project--superprojectBranchSlug" {
  _mock_defaults
  context-raw() { REPLY="parent▮feature-branch▮/worktrees/parent--feature-branch"; }
  git-branch-slug() { echo "feature-branch"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "parent--feature-branch" ]]
}

@test "--project and --branch: forwarded to context-raw" {
  context-raw() {
    echo "$@" > "$BATS_TMP_DIR/raw-args.txt"
    REPLY="myapp▮feat/x▮/repos/myapp"
  }
  git-branch-slug() { echo "feat_x"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug --project myapp --branch feat/x"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myapp--feat_x" ]]
  local args="$(cat "$BATS_TMP_DIR/raw-args.txt")"
  [[ "$args" == *"--project"* ]]
  [[ "$args" == *"myapp"* ]]
  [[ "$args" == *"--branch"* ]]
  [[ "$args" == *"feat/x"* ]]
}

@test "--project and --branch with path: path forwarded to context-raw" {
  context-raw() {
    echo "$@" > "$BATS_TMP_DIR/raw-args.txt"
    REPLY="myapp▮my-branch▮/repos/myapp"
  }
  git-branch-slug() { echo "my-branch"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug --project myapp --branch my-branch /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myapp--my-branch" ]]
  local args="$(cat "$BATS_TMP_DIR/raw-args.txt")"
  [[ "$args" == *"/some/path"* ]]
}

@test "--branch with slashes: branch is slugified" {
  _mock_defaults
  context-raw() { REPLY="oroshi▮feat/deep/nested▮/repos/oroshi"; }
  git-branch-slug() { echo "feat_deep_nested"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug --branch feat/deep/nested"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi--feat_deep_nested" ]]
}

@test "--project only in worktree: overrides project, branch from context" {
  context-raw() {
    echo "$@" > "$BATS_TMP_DIR/raw-args.txt"
    REPLY="myapp▮feat/something▮/worktrees/myapp--feat_something"
  }
  git-branch-slug() { echo "feat_something"; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug --project myapp"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myapp--feat_something" ]]
  local args="$(cat "$BATS_TMP_DIR/raw-args.txt")"
  [[ "$args" == *"--project"* ]]
  [[ "$args" == *"myapp"* ]]
}

@test "explicit path: forwards path to context-raw" {
  context-raw() {
    echo "$@" > "$BATS_TMP_DIR/raw-args.txt"
    REPLY="other-repo▮▮/repos/other-repo"
  }
  git-branch-slug() { echo ""; }
  bats_mock context-raw git-branch-slug
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug /some/other/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "other-repo" ]]
  local args="$(cat "$BATS_TMP_DIR/raw-args.txt")"
  [[ "$args" == *"/some/other/path"* ]]
}

@test "empty branch from context-raw: no separator appended" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi" ]]
  [[ "$output" != *"--"* ]]
}
