bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "no slug: exits with error" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest"
  [ "$status" -ne 0 ]
}

@test "calls git-worktree-create with slug" {
  git-worktree-create() { echo "WORKTREE:$*"; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug"
  bats_debug "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == "WORKTREE:my-slug" ]]
}

@test "calls kitty-tab-create with slug as title and worktree path as cwd" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TAB:my-slug"* ]]
  [[ "$output" == *"--cwd $BATS_TMP_DIR/myrepo--my-slug"* ]]
}

@test "calls kitty-tab-create with --cmd kitty-helper-claude-start when no prompt given" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cmd kitty-helper-claude-start"* ]]
}

@test "calls kitty-tab-create with prompt appended to --cmd when --prompt given" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug --prompt @/tmp/fix-ralph.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cmd kitty-helper-claude-start @/tmp/fix-ralph.md"* ]]
}

@test "calls kitty-tab-create with --focus by default" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--focus"* ]]
}

@test "calls kitty-tab-create without --focus when --no-focus passed" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest my-slug --no-focus"
  [ "$status" -eq 0 ]
  [[ "$output" != *"--focus"* ]]
}
