bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/worktree/git-worktree-list-raw"
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/dark-mode'
}

teardown() {
  bats_cleanup
}

@test "lists worktrees with branch and path on each line" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮${BATS_GIT_WORKTREES}feat-dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮${BATS_GIT_WORKTREES}fix-bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  for line in "${lines[@]}"; do
    [[ "$line" != *"$BATS_GIT_DIR "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "delegates ahead/behind to git-worktree-distance-raw" {
  bats_git_dir 'stub-repo'
  bats_git_worktree 'feature'
  cat > "$BATS_TMP_DIR/mock.zsh" <<'MOCK'
git-worktree-distance-raw() { echo "7▮3"; }
MOCK
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feature▮"*"▮0▮7▮3▮"* ]]
}
