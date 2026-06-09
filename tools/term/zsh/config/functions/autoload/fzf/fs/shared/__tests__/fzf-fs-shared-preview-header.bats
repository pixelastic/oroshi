bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../fzf-fs-shared-preview-header"
  bats_git_worktree 'fix/bug'

  projects-load-definitions() {
    typeset -gA PROJECTS
    PROJECTS[my-project:path]="$BATS_GIT_DIR/"
    PROJECTS[my-project:background:ansi]=100
    PROJECTS[my-project:foreground:ansi]=255
    PROJECTS[my-project:icon]=X
    # shellcheck disable=SC2034
    PROJECTS[my-project:hideNameInPrompt]=false
  }
  bats_mock projects-load-definitions

  typeset -gA COLORS
  # shellcheck disable=SC2034
  COLORS[directory]=2
  # shellcheck disable=SC2034
  COLORS[comment]=8
}

teardown() {
  bats_cleanup
}

@test "header badge contains branch name when directory is inside linked worktree" {
  bats_run_zsh "$CURRENT" "${BATS_GIT_WORKTREES}fix-bug"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
