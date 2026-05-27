bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns project name for path inside registered project" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-project ${BATS_GIT_DIR}/src"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "returns project name for path inside linked worktree of registered project" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-project ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "worktree inside catch-all project returns the specific project not catch-all" {
  run zsh -c "PROJECTS_INDEX_BY_PATH='CATCHALL MYKEY'; PROJECT_CATCHALL_PATH=${BATS_TMP_DIR}/; PROJECT_CATCHALL_NAME=catch-all; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-project ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "returns empty string for path outside all registered projects" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=; context-project /tmp/unregistered-dir"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
