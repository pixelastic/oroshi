bats_load_library 'helper'

# Mock all collaborators for unit tests
_mock_defaults() {
  git-github-project-name() { echo "oroshi"; }
  git-directory-is-worktree() { return 1; }
  git-directory-root() { echo "/home/user/repos/oroshi"; }
  git-branch-slug() { echo "yarn-sync"; }
  bats_mock git-github-project-name git-directory-is-worktree git-directory-root git-branch-slug
}

setup() {
  bats_tmp_dir
}

@test "in main repo: returns repo name from github" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi" ]]
}

@test "in worktree: returns repoName--branchSlug" {
  _mock_defaults
  git-directory-is-worktree() { return 0; }
  bats_mock git-directory-is-worktree
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "oroshi--yarn-sync" ]]
}

@test "github fallback: uses git root basename with leading dot stripped" {
  _mock_defaults
  git-github-project-name() { return 1; }
  git-directory-root() { echo "/home/user/repos/.dotfiles"; }
  bats_mock git-github-project-name git-directory-root
  bats_run_zsh "cd $BATS_TMP_DIR && context-slug"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "dotfiles" ]]
}

@test "explicit path: resolves slug from target path, not PWD" {
  bats_git_dir 'other-repo'
  bats_git remote add origin git@github.com:someone/other-repo.git
  bats_disable_worktree_aware
  bats_run_zsh "context-slug $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "other-repo" ]]
}
