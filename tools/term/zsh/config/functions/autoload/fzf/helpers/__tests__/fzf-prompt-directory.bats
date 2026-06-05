bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fzf/helpers/fzf-prompt-directory"
  bats_git_worktree 'fix/bug'

  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[my-project:path]="$BATS_GIT_DIR/"
    PROJECTS[my-project:background:ansi]=100
    PROJECTS[my-project:foreground:ansi]=255
    PROJECTS[my-project:icon]=X
    PROJECTS[my-project:hideNameInPrompt]=false
  }
  bats_mock projects-load-definitions

  export COLOR_ALIAS_GIT_BRANCH=17
  export COLOR_ALIAS_DIRECTORY=2
}

teardown() {
  bats_cleanup
}

@test "prompt badge contains branch name when inside linked worktree" {
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
