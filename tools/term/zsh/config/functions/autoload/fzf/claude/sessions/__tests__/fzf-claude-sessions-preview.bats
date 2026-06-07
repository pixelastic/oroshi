bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ZSH_AUTOLOAD/fzf/claude/sessions/fzf-claude-sessions-preview"
  bats_git_worktree 'fix/bug'
  printf '{"cwd":"%s","updatedAt":"2026-01-01","firstMessage":"hello"}\n' "${BATS_GIT_WORKTREES}fix-bug" > "${BATS_TMP_DIR}/session.json"

  claude-session-data() { cat "$BATS_TMP_DIR/session.json"; }
  bats_mock claude-session-data

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
  export COLOR_ALIAS_DATE=11
}

teardown() {
  bats_cleanup
}

@test "preview contains branch name for worktree session" {
  bats_run_zsh "$CURRENT" abc123
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
