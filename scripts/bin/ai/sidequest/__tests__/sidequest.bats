bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../sidequest"
  export OROSHI_WORKTREES_DIR_MOCK="$BATS_TMP_DIR/worktrees"
}

teardown() {
  bats_cleanup
}

@test "no slug: exits with error" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT"
  [ "$status" -ne 0 ]
}

@test "calls git-worktree-create with slug" {
  git-worktree-create() { echo "WORKTREE:$*"; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == "WORKTREE:my-slug" ]]
}

@test "calls kitty-tab-create with slug as title and worktree path as cwd" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TAB:my-slug"* ]]
  [[ "$output" == *"--cwd $BATS_TMP_DIR/myrepo--my-slug"* ]]
}

@test "calls kitty-tab-create with --cmd kitty-helper-claude-start when no prompt given" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cmd kitty-helper-claude-start"* ]]
}

@test "calls kitty-tab-create with prompt appended to --cmd when --prompt given" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug" --prompt "@/tmp/fix-ralph.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cmd kitty-helper-claude-start @/tmp/fix-ralph.md"* ]]
}

@test "calls kitty-tab-create with --focus by default" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--focus"* ]]
}

@test "calls kitty-tab-create without --focus when --no-focus passed" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "$CURRENT" "my-slug" --no-focus
  [ "$status" -eq 0 ]
  [[ "$output" != *"--focus"* ]]
}
