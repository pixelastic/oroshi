bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
}

@test "creates worktree directory with correct name" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [ "$status" -eq 0 ]
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "creates the branch if it does not exist" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/new-branch"
  run git -C "$BATS_GIT_DIR" branch --list fix/new-branch
  [ "$output" != "" ]
}

@test "does not fail if branch already exists" {
  bats_git branch fix/existing
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/existing"
  [ "$status" -eq 0 ]
}

@test "cds into the created worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug && echo \$PWD"
  [ "$status" -eq 0 ]
  [ "$output" = "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}

@test "is idempotent — does not fail if worktree already exists" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [ "$status" -eq 0 ]
}

@test "converts slashes to underscores in directory name" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create feat/some/deep-branch"
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--feat_some_deep-branch" ]
}

@test "returns 1 outside any git repo" {
  bats_run_zsh "cd $BATS_TMP_DIR && git-worktree-create fix/bug"
  [ "$status" -eq 1 ]
}

@test "succeeds even when not on main" {
  bats_git checkout -b fix/current
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/other"
  [ "$status" -eq 0 ]
}

@test "new branch is based on main, not current branch" {
  bats_git commit --quiet --allow-empty -m "main commit"
  local mainSha
  mainSha="$(bats_git rev-parse main)"
  bats_git checkout -b fix/current
  bats_git commit --quiet --allow-empty -m "extra commit on current branch"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/new"
  local newBranchSha
  newBranchSha="$(git -C "$BATS_GIT_DIR" rev-parse fix/new)"
  [ "$newBranchSha" = "$mainSha" ]
}

@test "strips leading dot from repo name in dot-prefixed repo folder" {
  bats_git_dir '.dot-repo'
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [ "$status" -eq 0 ]
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/dot-repo--fix_bug" ]
}

@test "runs yarn install when yarn.lock is present" {
  yarn() { mkdir -p node_modules; }
  bats_mock yarn
  touch "$BATS_GIT_DIR/yarn.lock"
  bats_git add .
  bats_git commit --quiet -m "add yarn.lock"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/yarn"
  [ "$status" -eq 0 ]
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_yarn/node_modules" ]
}

@test "does not run yarn install when yarn.lock is absent" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/no-yarn"
  [ "$status" -eq 0 ]
  [ ! -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_no-yarn/node_modules" ]
}

@test "failing yarn install does not prevent worktree creation" {
  yarn() { return 1; }
  bats_mock yarn
  touch "$BATS_GIT_DIR/yarn.lock"
  bats_git add .
  bats_git commit --quiet -m "add yarn.lock"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/yarn"
  [ "$status" -eq 0 ]
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_yarn" ]
}

@test "re-entering existing worktree does not re-run yarn install" {
  yarn() {
    echo called >> "$BATS_TMP_DIR/yarn-calls"
    mkdir -p node_modules
  }
  bats_mock yarn
  touch "$BATS_GIT_DIR/yarn.lock"
  bats_git add .
  bats_git commit --quiet -m "add yarn.lock"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/yarn"
  local calls_first
  calls_first="$(wc -l < "$BATS_TMP_DIR/yarn-calls" 2>/dev/null || echo 0)"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/yarn"
  local calls_second
  calls_second="$(wc -l < "$BATS_TMP_DIR/yarn-calls" 2>/dev/null || echo 0)"
  [ "$calls_second" -eq "$calls_first" ]
}
