bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$BATS_TEST_DIRNAME/../fzf-claude-sessions-source-no-query"
  bats_git_worktree 'fix/bug'
  local sep=$'\u25ae'
  printf '%s\n' "abc123${sep}${BATS_GIT_WORKTREES}fix-bug${sep}${sep}5${sep}My Session" > "${BATS_TMP_DIR}/sessions.txt"

  claude-session-list-raw() { cat "$BATS_TMP_DIR/sessions.txt"; }
  bats_mock claude-session-list-raw

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

  export COLOR_ALIAS_GIT_BRANCH=17
  export COLOR_ALIAS_COMMENT=8
}

teardown() {
  bats_cleanup
}

@test "session output contains branch name for worktree cwd" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
