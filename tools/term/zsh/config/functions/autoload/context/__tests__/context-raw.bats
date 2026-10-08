bats_load_library 'helper'

# Default mocks: regular repo, not in submodule, not a worktree
_mock_defaults() {
  git() { echo ""; }
  project-name() { echo "myproject"; }
  git-github-project-name() { echo "myproject"; }
  git-directory-is-worktree() { return 1; }
  git-directory-root() { echo "/repos/myproject"; }
  git-branch-current() { echo "feat/something"; }
  project-path() { echo "/repos/myproject"; }
  projects-load-definitions() { true; }
  bats_mock git project-name git-github-project-name git-directory-is-worktree git-directory-root git-branch-current project-path projects-load-definitions
}

setup() {
  bats_tmp_dir
}

@test "regular repo: returns project▮▮root" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myproject▮▮/repos/myproject" ]]
}

@test "worktree: returns project▮branch▮root" {
  _mock_defaults
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/worktrees/myproject--feat_something"; }
  git-branch-current() { echo "feat/something"; }
  bats_mock git-directory-is-worktree git-directory-root git-branch-current
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myproject▮feat/something▮/worktrees/myproject--feat_something" ]]
}

@test "submodule-in-worktree: returns project▮superprojectBranch▮superprojectRoot" {
  _mock_defaults
  git() { echo "/worktrees/parent--branch"; }
  git-directory-is-worktree() { return 0; }
  git-directory-root() { echo "/worktrees/parent--branch"; }
  git-branch-current() { echo "feature-branch"; }
  git-directory-name() { echo "parent"; }
  bats_mock git git-directory-is-worktree git-directory-root git-branch-current git-directory-name
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /some/submodule/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "parent▮feature-branch▮/worktrees/parent--branch" ]]
}

# Real (unmocked) repo "parent" with a real submodule at ./private
_real_submodule_setup() {
  bats_git_dir 'parent' > /dev/null
  bats_git_submodule "$BATS_GIT_DIR" 'private'
  bats_disable_worktree_aware
}

@test "submodule in a regular checkout: returns superproject▮▮superprojectRoot" {
  _real_submodule_setup
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw $BATS_TMP_DIR/parent/private"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "parent▮▮$BATS_TMP_DIR/parent" ]]
}

@test "submodule in a regular checkout: context-root returns the superproject root" {
  _real_submodule_setup
  bats_run_zsh "cd $BATS_TMP_DIR && context-root $BATS_TMP_DIR/parent/private"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_TMP_DIR/parent" ]]
}

@test "submodule in a regular checkout: context-path includes the submodule directory" {
  _real_submodule_setup
  bats_run_zsh "cd $BATS_TMP_DIR && context-path $BATS_TMP_DIR/parent/private"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "private" ]]
}

@test "unregistered repo: returns project▮▮gitRoot" {
  bats_git_dir 'plain' > /dev/null
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw $BATS_TMP_DIR/plain"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "plain▮▮$BATS_TMP_DIR/plain" ]]
}

@test "--project override outside a git repo: returns empty root" {
  bats_tmp_dir
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw --project custom $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "custom▮▮" ]]
}

@test "--project override: replaces auto-detected project" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw --project custom /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "custom▮▮/repos/myproject" ]]
}

@test "--branch override: forces branch even in non-worktree" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw --branch feat/x /some/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myproject▮feat/x▮/repos/myproject" ]]
}

@test "--reply: writes to REPLY instead of stdout" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw --reply /some/path && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myproject▮▮/repos/myproject" ]]
}

@test "outside any project: returns empty string" {
  _mock_defaults
  project-name() { echo ""; }
  git-github-project-name() { return 1; }
  git-directory-root() { return 1; }
  bats_mock project-name git-github-project-name git-directory-root
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /tmp/random"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
