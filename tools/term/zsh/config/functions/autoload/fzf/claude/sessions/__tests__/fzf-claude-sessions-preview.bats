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
  echo "typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; PROJECTS[my-project.background.ansi]=100; PROJECTS[my-project.foreground.ansi]=255; PROJECTS[my-project.icon]=X; PROJECTS[my-project.hideNameInPrompt]=false; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_COMMENT=8; COLOR_ALIAS_DATE=11"
}

@test "preview contains branch name for worktree session" {
  run zsh -c "function claude-session-data { cat '${BATS_TMP_DIR}/session.json'; }; $(project_env); fzf-claude-sessions-preview abc123"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fix/bug"* ]]
}
