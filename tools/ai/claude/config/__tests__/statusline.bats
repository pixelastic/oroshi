bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feat/my-feature'

  mkdir -p "${BATS_TMP_DIR}/theming/env"

  printf '%s\n' \
    'COLOR_RED=1; COLOR_YELLOW=3; COLOR_GREEN=2; COLOR_GRAY=8' \
    'COLOR_AMBER_9=214; COLOR_ALIAS_GIT_BRANCH=17; COLOR_ALIAS_PUNCTUATION=8' \
    > "${BATS_TMP_DIR}/theming/env/colors.zsh"

  printf 'typeset -gA PROJECTS=(\n  [my-project.path]="%s/"\n  [my-project.background.ansi]="100"\n  [my-project.foreground.ansi]="255"\n  [my-project.icon]=""\n  [my-project.hideNameInPrompt]="false"\n)\n' \
    "${BATS_GIT_DIR}" > "${BATS_TMP_DIR}/theming/env/projects.zsh"
}

teardown() {
  bats_cleanup
}

statusline_json() {
  local dir="$1"
  printf '{"workspace":{"current_dir":"%s"},"model":{"display_name":"test"},"cost":{"total_cost_usd":0},"context_window":{"current_usage":{"input_tokens":0,"output_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0},"used_percentage":0},"session_id":"test"}' "$dir"
}

statusline_run() {
  local dir="$1"
  local json_file="${BATS_TMP_DIR}/input.json"
  statusline_json "$dir" > "$json_file"
  run zsh -c "export ZSH_CONFIG_PATH='${BATS_TMP_DIR}'; source '${OROSHI_ROOT}/tools/ai/claude/config/statusline'" < "$json_file"
}

@test "no separate git-branch-current call remains" {
  run grep "git-branch-current" "$OROSHI_ROOT/tools/ai/claude/config/statusline"
  [ "$status" -ne 0 ]
}

@test "shows project name for worktree path" {
  statusline_run "${BATS_GIT_WORKTREES}feat-my-feature"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
}

@test "shows branch name for worktree path" {
  statusline_run "${BATS_GIT_WORKTREES}feat-my-feature"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat/my-feature"* ]]
}

@test "shows no branch for main repo path" {
  statusline_run "${BATS_GIT_DIR}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" != *"main"* ]]
}
