bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  bats_git_worktree 'feat/dark-mode'
}

@test "lists worktrees with branch and path on each line" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feat/dark-mode▮${BATS_GIT_WORKTREES}my-repo--feat-dark-mode▮"* ]]
  [[ "${lines[1]}" == "fix/bug▮${BATS_GIT_WORKTREES}my-repo--fix-bug▮"* ]]
}

@test "excludes the Git Repo Main from output" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  for line in "${lines[@]}"; do
    [[ "$line" != *"$BATS_GIT_DIR "* ]]
  done
}

@test "returns empty output when no worktrees exist" {
  bats_git_dir 'clean-repo'
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "works from inside a linked worktree" {
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-list-raw"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "delegates ahead/behind to git-worktree-distance-raw" {
  bats_git_dir 'stub-repo'
  bats_git_worktree 'feature'
  git-worktree-distance-raw() { echo "7▮3"; }
  bats_mock git-worktree-distance-raw
  bats_run_zsh "cd $BATS_GIT_DIR && git-worktree-list-raw"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "feature▮"*"▮0▮7▮3▮"* ]]
}
