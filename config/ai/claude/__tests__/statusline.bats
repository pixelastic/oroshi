bats_load_library 'helper'

statusline_json() {
  local dir="$1"
  printf '{"workspace":{"current_dir":"%s"},"model":{"display_name":"test"},"cost":{"total_cost_usd":0},"context_window":{"current_usage":{"input_tokens":0,"output_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0},"used_percentage":0},"session_id":"test"}' "$dir"
}

statusline_run() {
  local dir="$1"
  local json="$(statusline_json "$dir")"
  run zsh -c "printf '%s' '${json}' | zsh '${OROSHI_ROOT}/config/ai/claude/statusline'"
}

@test "no separate git-branch-current call remains" {
  run grep "git-branch-current" "$OROSHI_ROOT/config/ai/claude/statusline"
  [ "$status" -ne 0 ]
}

@test "shows oroshi project for worktree path" {
  statusline_run "/home/tim/local/www/worktrees/oroshi--context-badge"
  [ "$status" -eq 0 ]
  [[ "$output" == *"oroshi"* ]]
}

@test "shows branch name for worktree path" {
  statusline_run "/home/tim/local/www/worktrees/oroshi--context-badge"
  [ "$status" -eq 0 ]
  [[ "$output" == *"context-badge"* ]]
}

@test "shows no branch for main repo path" {
  statusline_run "${HOME}/.oroshi"
  [ "$status" -eq 0 ]
  [[ "$output" == *"oroshi"* ]]
  [[ "$output" != *"main"* ]]
}
