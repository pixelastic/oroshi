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
  project-name() { echo "parent"; }
  bats_mock git git-directory-is-worktree git-directory-root git-branch-current project-name
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /some/submodule/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "parent▮feature-branch▮/worktrees/parent--branch" ]]
}

@test "submodule-in-non-worktree: returns project▮▮root" {
  _mock_defaults
  git() { echo "/repos/parent"; }
  bats_mock git
  bats_run_zsh "cd $BATS_TMP_DIR && context-raw /some/submodule/path"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "myproject▮▮/repos/myproject" ]]
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
