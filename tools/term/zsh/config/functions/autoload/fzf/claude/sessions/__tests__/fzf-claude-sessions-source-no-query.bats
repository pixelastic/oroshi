bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  local sep=$'\u25ae'
  printf '%s\n' "abc123${sep}${BATS_GIT_WORKTREES}fix-bug${sep}${sep}5${sep}My Session" > "${BATS_TMP_DIR}/sessions.txt"

  claude-session-list-raw() { cat "$BATS_TMP_DIR/sessions.txt"; }
  bats_mock claude-session-list-raw

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
  export COLOR_ALIAS_COMMENT=8
}

teardown() {
  bats_cleanup
}

@test "session output contains branch name for worktree cwd" {
  bats_run_function fzf-claude-sessions-source-no-query
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
