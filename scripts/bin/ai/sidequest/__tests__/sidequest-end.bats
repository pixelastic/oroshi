bats_load_library 'helper'

setup() {
  bats_tmp_dir
  touch "$BATS_TMP_DIR/my-slug.md"
}

@test "no argument: exits with error" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end"
  [ "$status" -ne 0 ]
}

@test "file not found: exits with error" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end /nonexistent/file.md"
  [ "$status" -ne 0 ]
}

@test "valid file: calls git-worktree-create with slug derived from filename" {
  git-worktree-create() { echo "WORKTREE:$*"; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md"
  bats_debug "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == "WORKTREE:my-slug" ]]
}

@test "valid file: calls kitty-tab-create with worktree path as cwd" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cwd $BATS_TMP_DIR/myrepo--my-slug"* ]]
}

@test "valid file: calls kitty-tab-create with filepath as prompt in --cmd" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--cmd kitty-helper-claude-start @$BATS_TMP_DIR/my-slug.md"* ]]
}

@test "valid file: calls kitty-tab-create without --focus" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { echo "TAB:$*"; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md"
  [ "$status" -eq 0 ]
  [[ "$output" != *"--focus"* ]]
}

@test "--repo-dir with nonexistent path: exits with error" {
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md --repo-dir /nonexistent/path"
  [ "$status" -ne 0 ]
}

@test "--repo-dir with non-git directory: exits with error" {
  git-directory-is-repository() { return 1; }
  git-worktree-create() { return 0; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-directory-is-repository git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md --repo-dir $BATS_TMP_DIR"
  [ "$status" -ne 0 ]
}

@test "--repo-dir with valid git repo: calls git-worktree-create with slug" {
  git-directory-is-repository() { return 0; }
  git-worktree-create() { echo "WORKTREE:$*"; }
  git-worktree-path() { echo "$BATS_TMP_DIR/myrepo--my-slug"; }
  kitty-tab-create() { return 0; }
  bats_mock git-directory-is-repository git-worktree-create git-worktree-path kitty-tab-create

  bats_run_zsh "sidequest-end $BATS_TMP_DIR/my-slug.md --repo-dir $BATS_TMP_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == "WORKTREE:my-slug" ]]
}
