bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "returns worktree root for path inside linked worktree" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-root ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_WORKTREES}fix-bug" ]
}

@test "returns project root for path inside project not a worktree" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${BATS_GIT_DIR}/; PROJECT_MYKEY_NAME=my-project; context-root ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "${BATS_GIT_DIR}" ]
}

@test "returns empty string for path outside all known projects" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=; context-root /tmp/unregistered-dir"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
