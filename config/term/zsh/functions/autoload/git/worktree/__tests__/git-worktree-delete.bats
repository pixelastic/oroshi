load '../../../../../../../../scripts/bin/__tests__/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export OROSHI_WORKTREES_DIR="$TMP_DIRECTORY/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "removes the worktree directory" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "deletes the branch" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug
  run git -C "$TMP_DIRECTORY/my-repo" branch --list fix/bug
  [ "$output" = "" ]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  # Uses subshell + echo "$PWD" — only way bats can observe a cd side-effect
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run zsh -c 'git-worktree-delete fix/bug && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$TMP_DIRECTORY/my-repo" ]
}

@test "blocks deletion if branch has commits ahead of main" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug
  [ "$status" -eq 1 ]
  [ -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
  [[ "$output" == *"unmerged"* ]]
}

@test "--force bypasses the unmerged commits check" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug --force
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "-f bypasses the unmerged commits check" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete fix/bug -f
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "defaults to current branch when called with no argument from inside a worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run zsh -c 'git-worktree-delete && echo "$PWD"'
  [ "$status" -eq 0 ]
  [ ! -d "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
  [ "${lines[-1]}" = "$TMP_DIRECTORY/my-repo" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-delete nonexistent/branch
  [ "$status" -eq 1 ]
}
