bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "PROJECTS_INDEX_BY_PATH=MY_PROJECT; PROJECT_MY_PROJECT_PATH=${BATS_GIT_DIR}/; PROJECT_MY_PROJECT_NAME=my-project; PROJECT_MY_PROJECT_BACKGROUND=100; PROJECT_MY_PROJECT_FOREGROUND=255; PROJECT_MY_PROJECT_ICON=X; PROJECT_MY_PROJECT_HIDE_NAME_IN_PROMPT=0; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_DIRECTORY=2; COLOR_ALIAS_COMMENT=8"
}

@test "header badge contains branch name when directory is inside linked worktree" {
  run zsh -c "$(project_env); fzf-fs-shared-preview-header ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
