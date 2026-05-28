bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; PROJECTS[my-project.background.ansi]=100; PROJECTS[my-project.foreground.ansi]=255; PROJECTS[my-project.icon]=X; PROJECTS[my-project.hideNameInPrompt]=false; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_DIRECTORY=2; COLOR_ALIAS_COMMENT=8"
}

@test "header badge contains branch name when directory is inside linked worktree" {
  run zsh -c "$(project_env); fzf-fs-shared-preview-header ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
