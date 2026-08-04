bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  cd "$BATS_GIT_DIR" || return 1
  git checkout --quiet -b fix/bug
  git checkout --quiet main
  git commit --allow-empty --quiet -m "main work"
  git checkout --quiet fix/bug
}

@test "rebases fix/bug on top of main" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-pull"
  [[ "$status" -eq 0 ]]
}

@test "fix/bug contains main commits after pull" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-pull"
  run git log --oneline
  [[ "$output" == *"main work"* ]]
}

@test "calls git-dependencies-update with pre-rebase commit after successful rebase" {
  git-dependencies-update() { echo "$@" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  cd "$BATS_GIT_DIR"
  local preRebaseCommit="$(git rev-parse HEAD)"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-pull"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "$preRebaseCommit" ]]
}

@test "does not call git-dependencies-update when rebase fails" {
  git-dependencies-update() { echo "called" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  # Create a conflict: modify same file on main and fix/bug
  cd "$BATS_GIT_DIR"
  git checkout --quiet main
  echo "main content" > conflict.txt
  git add conflict.txt
  git commit --quiet -m "main change"
  git checkout --quiet fix/bug
  echo "bug content" > conflict.txt
  git add conflict.txt
  git commit --quiet -m "bug change"

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-pull"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/dep-update-calls" ]]
}

@test "returns 1 if main does not exist" {
  git init --quiet "$BATS_TMP_DIR/no-main"
  git -C "$BATS_TMP_DIR/no-main" config user.email "bats@oroshi"
  git -C "$BATS_TMP_DIR/no-main" config user.name "Bats"
  git -C "$BATS_TMP_DIR/no-main" symbolic-ref HEAD refs/heads/develop
  git -C "$BATS_TMP_DIR/no-main" commit --allow-empty --quiet -m "init"
  git -C "$BATS_TMP_DIR/no-main" checkout --quiet -b fix/bug
  cd "$BATS_TMP_DIR/no-main"
  bats_run_zsh "git-worktree-pull"
  [[ "$status" -ne 0 ]]
}
