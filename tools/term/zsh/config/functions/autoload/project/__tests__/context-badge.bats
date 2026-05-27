bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "PROJECTS_INDEX_BY_PATH=MY_PROJECT; PROJECT_MY_PROJECT_PATH=${BATS_GIT_DIR}/; PROJECT_MY_PROJECT_NAME=my-project; PROJECT_MY_PROJECT_BACKGROUND=100; PROJECT_MY_PROJECT_FOREGROUND=255; PROJECT_MY_PROJECT_ICON=X; PROJECT_MY_PROJECT_HIDE_NAME_IN_PROMPT=0; COLOR_ALIAS_GIT_BRANCH=17"
}

@test "contains project name and no branch for path inside Git Repo Main" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR}/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" != *"main"* ]]
}

@test "contains project name and branch name for path inside linked worktree" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" == *"fix/bug"* ]]
}

@test "project name argument produces same output as project root path" {
  run zsh -c "$(project_env); context-badge my-project"
  [ "$status" -eq 0 ]
  local by_name="$output"
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [ "$by_name" = "$output" ]
}

@test "returns empty output for path outside all known projects" {
  run zsh -c "PROJECTS_INDEX_BY_PATH=; context-badge /tmp/unregistered-dir"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "output contains ANSI escape sequences for registered path" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "output does not contain zsh prompt codes" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [[ "$output" != *"%K{"* ]]
}

@test "--zsh flag output contains zsh prompt codes" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR} --zsh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"%K{"* ]]
}

@test "--zsh flag output does not contain raw ANSI sequences" {
  run zsh -c "$(project_env); context-badge ${BATS_GIT_DIR} --zsh"
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}
