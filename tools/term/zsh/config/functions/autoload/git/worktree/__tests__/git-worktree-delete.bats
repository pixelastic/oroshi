bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-delete"
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "removes the worktree directory" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "deletes the branch" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  run bats_git branch --list fix/bug
  [ "$output" = "" ]
}

@test "cds to Git Repo Main when called from inside the deleted worktree" {
  # Uses subshell + echo "$PWD" — only way bats can observe a cd side-effect
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/cd-test.zsh"
  printf 'git-worktree-delete fix/bug && echo "$PWD"\n' >"$script"
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}

@test "blocks deletion if branch has commits ahead of main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [[ "$output" == *"unmerged"* ]]
}

@test "--force bypasses the unmerged commits check" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug --force
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "-f bypasses the unmerged commits check" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug -f
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "defaults to current branch when called with no argument from inside a worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/cd-test-noarg.zsh"
  printf 'git-worktree-delete && echo "$PWD"\n' >"$script"
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}

@test "returns 1 if worktree does not exist" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" nonexistent/branch
  [ "$status" -eq 1 ]
}

@test "removes multiple worktrees" {
  bats_git_worktree 'feat/thing'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug feat/thing
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [ ! -d "${BATS_GIT_WORKTREES}feat-thing" ]
}

@test "deletes multiple branches" {
  bats_git_worktree 'feat/thing'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug feat/thing
  run bats_git branch --list fix/bug
  [ "$output" = "" ]
  run bats_git branch --list feat/thing
  [ "$output" = "" ]
}

@test "stops at first failure when one branch has unmerged commits" {
  bats_git_worktree 'feat/thing'
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "unmerged commit"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug feat/thing
  [ "$status" -eq 1 ]
  [ -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [ -d "${BATS_GIT_WORKTREES}feat-thing" ]
}

@test "removes associated plans/ directory from main repo" {
  mkdir -p "$BATS_GIT_DIR/plans/fix_bug"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 0 ]
  [ ! -d "$BATS_GIT_DIR/plans/fix_bug" ]
}

@test "succeeds without plans/ directory" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" fix/bug
  [ "$status" -eq 0 ]
}
