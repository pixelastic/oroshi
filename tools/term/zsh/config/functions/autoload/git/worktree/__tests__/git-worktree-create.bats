bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"

  # Isolate from the project registry, whose catch-all "root" project (path /)
  # would otherwise name every repo "root"
  project-name() { :; }
  bats_mock project-name
}

# mock_generate_syntax <exitCode>
# Points OROSHI_ROOT at a temp dir holding a fake generate-syntax script that
# logs its call, then exits with <exitCode>
# Requires bats_disable_worktree_aware, so chpwd keeps the mocked OROSHI_ROOT
mock_generate_syntax() {
  local syntaxDirectory="$BATS_TMP_DIR/oroshi/tools/ai/claude/config/syntax"
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
  mkdir -p "$syntaxDirectory"
  printf '#!/bin/zsh\ntouch "$BATS_TMP_DIR/generate-syntax-called"\nexit %s\n' "$1" > "$syntaxDirectory/generate-syntax"
  chmod +x "$syntaxDirectory/generate-syntax"
}

@test "creates worktree directory with correct name" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [[ "$status" -eq 0 ]]
  [[ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]]
}

@test "creates the branch if it does not exist" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/new-branch"
  run git -C "$BATS_GIT_DIR" branch --list fix/new-branch
  [[ "$output" != "" ]]
}

@test "does not fail if branch already exists" {
  bats_git branch fix/existing
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/existing"
  [[ "$status" -eq 0 ]]
}

@test "cds into the created worktree" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug && echo \$PWD"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]]
}

@test "is idempotent — does not fail if worktree already exists" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [[ "$status" -eq 0 ]]
}

@test "converts slashes to underscores in directory name" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create feat/some/deep-branch"
  [[ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--feat_some_deep-branch" ]]
}

@test "returns 1 outside any git repo" {
  bats_run_zsh "cd $BATS_TMP_DIR && git-worktree-create fix/bug"
  [[ "$status" -eq 1 ]]
}

@test "succeeds even when not on main" {
  bats_git checkout -b fix/current
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/other"
  [[ "$status" -eq 0 ]]
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
  [[ "$newBranchSha" = "$mainSha" ]]
}

@test "strips leading dot from repo name in dot-prefixed repo folder" {
  bats_git_dir '.dot-repo'
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/bug"
  [[ "$status" -eq 0 ]]
  [[ -d "$MOCK_OROSHI_WORKTREES_DIR/dot-repo--fix_bug" ]]
}

@test "calls git-dependencies-update without origin commit" {
  git-dependencies-update() { echo "called:$*" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/deps"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/dep-update-calls" ]]
  # Called with no arguments (no origin commit)
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "called:" ]]
}

@test "calls prose-build when creating an oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  prose-build() { echo "called" >> "$BATS_TMP_DIR/prose-build-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware
  mock_generate_syntax 0

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/prose"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/prose-build-calls" ]]
}

@test "does not call prose-build for a non-oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  prose-build() { echo "called" >> "$BATS_TMP_DIR/prose-build-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/not-oroshi"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/prose-build-calls" ]]
}

@test "patches Claude syntax colors when creating an oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  prose-build() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware
  mock_generate_syntax 0

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/syntax"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/generate-syntax-called" ]]
}

@test "does not patch Claude syntax colors for a non-oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  prose-build() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware
  mock_generate_syntax 0

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/not-oroshi"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/generate-syntax-called" ]]
}

@test "warns and succeeds when Claude syntax patch fails" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  prose-build() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware
  mock_generate_syntax 1

  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-create fix/syntax-fail"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"✘ Could not patch Claude Code syntax colors"* ]]
}
