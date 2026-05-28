bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; PROJECTS[my-project.background.ansi]=100; PROJECTS[my-project.foreground.ansi]=255; PROJECTS[my-project.icon]=X; PROJECTS[my-project.hideNameInPrompt]=false; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_DIRECTORY=2"
}

@test "prompt badge contains branch name when inside linked worktree" {
  run zsh -c "$(project_env); fzf-prompt-directory ${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}

@test "no remaining project-by-path calls in fzf functions" {
  local fzfDir="${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/fzf"
  run grep -r --exclude-dir="__tests__" "project-by-path" "$fzfDir"
  [ "$status" -ne 0 ]
}
