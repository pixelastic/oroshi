bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  printf '{"cwd":"%s","updatedAt":"2026-01-01","firstMessage":"hello"}\n' "${BATS_GIT_WORKTREES}fix-bug" > "${BATS_TMP_DIR}/session.json"

  claude-session-data() { cat "$BATS_TMP_DIR/session.json"; }
  bats_mock claude-session-data

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
  export COLOR_ALIAS_DATE=11
}

teardown() {
  bats_cleanup
}

@test "preview contains branch name for worktree session" {
  bats_run_function fzf-claude-sessions-preview abc123
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
