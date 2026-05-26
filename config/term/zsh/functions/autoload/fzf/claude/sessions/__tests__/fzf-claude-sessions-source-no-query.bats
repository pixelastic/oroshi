bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  local sep=$'\u25ae'
  printf '%s\n' "abc123${sep}${BATS_GIT_WORKTREES}fix-bug${sep}${sep}5${sep}My Session" > "${BATS_TMP_DIR}/sessions.txt"
}

teardown() {
  bats_cleanup
}

project_env() {
  echo "PROJECTS_INDEX_BY_PATH=MY_PROJECT; PROJECT_MY_PROJECT_PATH=${BATS_GIT_DIR}/; PROJECT_MY_PROJECT_NAME=my-project; PROJECT_MY_PROJECT_BACKGROUND=100; PROJECT_MY_PROJECT_FOREGROUND=255; PROJECT_MY_PROJECT_ICON=X; PROJECT_MY_PROJECT_HIDE_NAME_IN_PROMPT=0; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_COMMENT=8"
}

@test "session output contains branch name for worktree cwd" {
  run zsh -c "function claude-session-list-raw { cat '${BATS_TMP_DIR}/sessions.txt'; }; $(project_env); fzf-claude-sessions-source-no-query"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
