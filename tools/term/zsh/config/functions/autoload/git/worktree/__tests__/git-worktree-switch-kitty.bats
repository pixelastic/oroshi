bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "no argument: exits with error" {
  git-worktree-main() { echo "$BATS_TMP_DIR/myrepo"; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--fix_bug"; }
  git-github-project-name() { echo "myrepo"; }
  git-branch-slug() { echo "fix_bug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-main git-worktree-path git-github-project-name git-branch-slug kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty"
  [[ "$status" -ne 0 ]]
}

@test "non-existent worktree: exits with error" {
  git-worktree-path() { echo ""; }
  git-branch-slug() { echo "nope_branch"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-path git-branch-slug kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty nope/branch"
  [[ "$status" -ne 0 ]]
}

@test "valid branch: calls kitty-tab-create with Branch Slug as tab title" {
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--fix_bug"; }
  git-branch-slug() { echo "fix_bug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-path git-branch-slug kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"TAB:fix_bug"* ]]
}

@test "valid branch: calls kitty-tab-create with --focus" {
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--fix_bug"; }
  git-branch-slug() { echo "fix_bug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-path git-branch-slug kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--focus"* ]]
}

@test "valid branch: calls kitty-tab-create with --cwd set to Worktree path" {
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--fix_bug"; }
  git-branch-slug() { echo "fix_bug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-path git-branch-slug kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty fix/bug"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--cwd $BATS_TMP_DIR/myrepo--fix_bug"* ]]
}

@test "main branch: calls kitty-tab-create with Repo Name as tab title" {
  git-worktree-main() { echo "$BATS_TMP_DIR/myrepo"; }
  git-github-project-name() { echo "myrepo"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-main git-github-project-name kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty main"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"TAB:myrepo"* ]]
}

@test "main branch: calls kitty-tab-create with --focus" {
  git-worktree-main() { echo "$BATS_TMP_DIR/myrepo"; }
  git-github-project-name() { echo "myrepo"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-main git-github-project-name kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty main"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--focus"* ]]
}

@test "main branch: calls kitty-tab-create with --cwd set to Git Repo Main path" {
  git-worktree-main() { echo "$BATS_TMP_DIR/myrepo"; }
  git-github-project-name() { echo "myrepo"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-main git-github-project-name kitty-tab-create

  bats_run_zsh "git-worktree-switch-kitty main"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--cwd $BATS_TMP_DIR/myrepo"* ]]
}
