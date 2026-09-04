bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
}

@test "returns 0 when pointers differ" {
  local worktree="${BATS_GIT_WORKTREES}my-repo--fix-bug"

  # Advance submodule pointer in worktree
  local upstream="$BATS_TMP_DIR/sub-upstream-my-sub"
  git -C "$upstream" commit --allow-empty --quiet -m "advance"
  local newHash="$(git -C "$upstream" rev-parse HEAD)"
  git -C "$worktree" update-index --cacheinfo "160000,$newHash,my-sub"
  git -C "$worktree" commit --quiet -m "update sub pointer"

  bats_run_zsh "cd $worktree && git-worktree-submodule-pointer-differs my-sub"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when pointers are identical" {
  local worktree="${BATS_GIT_WORKTREES}my-repo--fix-bug"

  bats_run_zsh "cd $worktree && git-worktree-submodule-pointer-differs my-sub"
  [[ "$status" -eq 1 ]]
}
