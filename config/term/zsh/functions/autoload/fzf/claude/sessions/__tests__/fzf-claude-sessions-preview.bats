bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  printf '{"cwd":"%s","updatedAt":"2026-01-01","firstMessage":"hello"}\n' "${BATS_GIT_WORKTREES}fix-bug" > "${BATS_TMP_DIR}/session.json"
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "PROJECTS_INDEX_BY_PATH=MY_PROJECT; PROJECT_MY_PROJECT_PATH=${BATS_GIT_DIR}/; PROJECT_MY_PROJECT_NAME=my-project; PROJECT_MY_PROJECT_BACKGROUND=100; PROJECT_MY_PROJECT_FOREGROUND=255; PROJECT_MY_PROJECT_ICON=X; PROJECT_MY_PROJECT_HIDE_NAME_IN_PROMPT=0; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_COMMENT=8; COLOR_ALIAS_DATE=11"
}

@test "preview contains branch name for worktree session" {
  run zsh -c "function claude-session-data { cat '${BATS_TMP_DIR}/session.json'; }; $(project_env); fzf-claude-sessions-preview abc123"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
