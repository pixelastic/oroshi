bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns project name when worktree main is a registered project" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; git-worktree-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "returns empty string when worktree main is not a registered project" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c "PROJECTS_INDEX_BY_PATH=; git-worktree-project"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
