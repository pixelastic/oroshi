bats_load_library 'helper'

RALPH_DIRECTORY="$BATS_TEST_DIRNAME/../ralph-directory"

setup() {
  bats_git_dir 'repo'
}

teardown() {
  bats_cleanup
}

@test "returns absolute path to ralph/<slug>/ in a ralph worktree" {
  local wt_path="$(bats_git_worktree 'feat/my-feat')"
  mkdir -p "$wt_path/ralph/feat_my-feat"
  echo '[]' >"$wt_path/ralph/feat_my-feat/issues.json"
  cd "$wt_path"
  bats_run_script "$RALPH_DIRECTORY"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/ralph/feat_my-feat/"* ]]
  [[ "$output" == /* ]]
}

@test "exits 1 when not in a ralph worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_script "$RALPH_DIRECTORY"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "exits 1 in a worktree without issues.json" {
  local wt_path="$(bats_git_worktree 'feat/no-prd')"
  cd "$wt_path"
  bats_run_script "$RALPH_DIRECTORY"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "accepts an explicit subpath argument" {
  local wt_path="$(bats_git_worktree 'feat/explicit')"
  mkdir -p "$wt_path/ralph/feat_explicit"
  echo '[]' >"$wt_path/ralph/feat_explicit/issues.json"
  bats_run_script "$RALPH_DIRECTORY" "$wt_path/ralph/feat_explicit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/ralph/feat_explicit/"* ]]
}
