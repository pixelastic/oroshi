bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  cd "$BATS_GIT_DIR" || return 1
  git checkout --quiet -b fix/bug
  git checkout --quiet main
  git commit --allow-empty --quiet -m "main work"
  git checkout --quiet fix/bug
}

teardown() {
  bats_cleanup
}

@test "rebases fix/bug on top of main" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-pull"
  [ "$status" -eq 0 ]
}

@test "fix/bug contains main commits after pull" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-worktree-pull"
  run git log --oneline
  [[ "$output" == *"main work"* ]]
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
  [ "$status" -ne 0 ]
}
