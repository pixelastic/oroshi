bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_GIT_WORKTREES"
}

teardown() {
  bats_cleanup
}

# 1-argument form
@test "1-arg: renames the branch" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}fix-bug && git-worktree-rename feat/new"
  [ "$status" -eq 0 ]
  run bats_git branch --list feat/new
  [[ "$output" != "" ]]
}

@test "1-arg: removes old directory and creates new one" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}fix-bug && git-worktree-rename feat/new"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feat_new" ]
}

@test "1-arg: worktree registered under new name in git worktree list" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}fix-bug && git-worktree-rename feat/new"
  [ "$status" -eq 0 ]
  run git -C "$BATS_GIT_DIR" worktree list
  [[ "$output" == *"feat/new"* ]]
}

# 2-argument form
@test "2-arg: renames the branch, replaces directories, registers in git" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 0 ]
  run bats_git branch --list feat/new
  [[ "$output" != "" ]]
  [ ! -d "${BATS_GIT_WORKTREES}fix-bug" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feat_new" ]
  run git -C "$BATS_GIT_DIR" worktree list
  [[ "$output" == *"feat/new"* ]]
}

# Blocking conditions
@test "fails with 1-arg when called from outside a linked worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename feat/new"
  [ "$status" -eq 1 ]
}

@test "fails if destination branch already exists" {
  bats_git branch feat/new
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 1 ]
  run bats_git branch --list fix/bug
  [[ "$output" != "" ]]
  [ -d "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "fails if destination directory already exists" {
  mkdir -p "${BATS_GIT_WORKTREES}my-repo--feat_new"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 1 ]
  run bats_git branch --list fix/bug
  [[ "$output" != "" ]]
}

@test "fails if destination plans directory already exists" {
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/plans/fix_bug"
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/plans/feat_new"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 1 ]
  run bats_git branch --list fix/bug
  [[ "$output" != "" ]]
}

# Plans artifact handling
@test "renames plans directory on success" {
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/plans/fix_bug"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 0 ]
  [ ! -d "${BATS_GIT_WORKTREES}my-repo--feat_new/plans/fix_bug" ]
  [ -d "${BATS_GIT_WORKTREES}my-repo--feat_new/plans/feat_new" ]
}

@test "succeeds without a plans directory" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new"
  [ "$status" -eq 0 ]
}

# cd side-effects
@test "navigates to new directory when called from inside the renamed worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}fix-bug && git-worktree-rename feat/new && echo \$PWD"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "${BATS_GIT_WORKTREES}my-repo--feat_new" ]
}

@test "stays in place when called from outside the renamed worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-rename fix/bug feat/new && echo \$PWD"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$BATS_GIT_DIR" ]
}
