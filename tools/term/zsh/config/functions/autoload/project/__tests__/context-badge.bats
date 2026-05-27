bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  PROJ="typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; PROJECTS[my-project.background.ansi]=100; PROJECTS[my-project.foreground.ansi]=255; PROJECTS[my-project.icon]=X; PROJECTS[my-project.hideNameInPrompt]=false; COLOR_ALIAS_GIT_BRANCH=17"
}

teardown() {
  bats_cleanup
}

@test "contains project name and no branch for path inside Git Repo Main" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR}/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" != *"main"* ]]
}

@test "contains project name and branch name for path inside linked worktree" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" == *"fix/bug"* ]]
}

@test "project name argument produces same output as project root path" {
  run zsh -c "${PROJ}; context-badge my-project"
  [ "$status" -eq 0 ]
  local by_name="$output"
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [ "$by_name" = "$output" ]
}

@test "returns empty output for path outside all known projects" {
  run zsh -c "${PROJ}; context-badge /tmp/unregistered-dir"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "output contains ANSI escape sequences for registered path" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "output does not contain zsh prompt codes" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [[ "$output" != *"%K{"* ]]
}

@test "--zsh flag output contains zsh prompt codes" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR} --zsh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"%K{"* ]]
}

@test "--zsh flag output does not contain raw ANSI sequences" {
  run zsh -c "${PROJ}; context-badge ${BATS_GIT_DIR} --zsh"
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}
