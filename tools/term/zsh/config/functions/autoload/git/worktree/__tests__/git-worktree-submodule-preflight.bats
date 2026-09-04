bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_submodule "$BATS_GIT_DIR" 'other-sub'
  bats_git_worktree 'fix/bug'

  # Mock immediate collaborators
  git-worktree-main() { echo "$BATS_GIT_DIR"; }
  git-submodule-list-raw() {
    printf 'my-sub▮abc12345▮main\nother-sub▮def67890▮main\n'
  }
  git-directory-dirty-count() { echo 0; }
  bats_mock git-worktree-main git-submodule-list-raw git-directory-dirty-count
  bats_disable_worktree_aware
}

# Advance main's submodule pointer, synced with upstream
_advance_synced() {
  local name="$1"
  local upstream="$BATS_TMP_DIR/sub-upstream-$name"
  git -C "$upstream" commit --allow-empty --quiet -m "upstream advance"
  git -C "$BATS_GIT_DIR/$name" fetch --quiet origin
  git -C "$BATS_GIT_DIR/$name" merge --quiet origin/main
  git -C "$BATS_GIT_DIR" add "$name"
  git -C "$BATS_GIT_DIR" commit --quiet -m "update $name"
}

# Advance main's submodule pointer with unpushed local commit
_advance_ahead() {
  local name="$1"
  git -C "$BATS_GIT_DIR/$name" commit --allow-empty --quiet -m "local only"
  git -C "$BATS_GIT_DIR" add "$name"
  git -C "$BATS_GIT_DIR" commit --quiet -m "update $name with local"
}

@test "no changed submodule pointers: returns 0, no output" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-submodule-preflight"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "changed pointer, main submodule clean and synced: returns 0" {
  _advance_synced 'my-sub'

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-submodule-preflight"
  [[ "$status" -eq 0 ]]
}

@test "changed pointer, main submodule dirty: returns 1 with error" {
  _advance_synced 'my-sub'

  # Override: submodule is dirty
  git-directory-dirty-count() { echo 3; }
  bats_mock git-directory-dirty-count

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-submodule-preflight"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"my-sub"* ]]
  [[ "$output" == *"commit"* ]]
}

@test "changed pointer, main submodule ahead of remote: returns 1 with error" {
  _advance_ahead 'my-sub'

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-submodule-preflight"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"my-sub"* ]]
  [[ "$output" == *"push"* ]]
}

@test "multiple submodules, one failing: identifies failing submodule" {
  _advance_synced 'my-sub'
  _advance_ahead 'other-sub'

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-submodule-preflight"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"other-sub"* ]]
}

@test "accepts worktree path as positional argument" {
  _advance_synced 'my-sub'

  bats_run_zsh "git-worktree-submodule-preflight ${BATS_GIT_WORKTREES}my-repo--fix-bug"
  [[ "$status" -eq 0 ]]
}
