bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'

  projects-load-definitions() {
    typeset -gA PROJECTS_V2
    PROJECTS_V2[my-project:path]="$BATS_GIT_DIR/"
    PROJECTS_V2[my-project:background:ansi]=100
    PROJECTS_V2[my-project:foreground:ansi]=255
    PROJECTS_V2[my-project:icon]=X
    PROJECTS_V2[my-project:hideNameInPrompt]=false
  }
  bats_mock projects-load-definitions

  export COLOR_ALIAS_GIT_BRANCH=17
  export COLOR_ALIAS_DIRECTORY=2
  export COLOR_ALIAS_COMMENT=8
}

teardown() {
  bats_cleanup
}

@test "header badge contains branch name when directory is inside linked worktree" {
  bats_run_function fzf-fs-shared-preview-header "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
