bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$BATS_TEST_DIRNAME/../plan-directory"
}

teardown() {
  bats_cleanup
}

@test "returns absolute path to plans/<slug>/ in a ralph worktree" {
  local wt_path="$(bats_git_worktree 'feat/my-feat')"
  mkdir -p "$wt_path/plans/feat_my-feat"
  echo '{}' >"$wt_path/plans/feat_my-feat/state.json"
  cd "$wt_path"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/plans/feat_my-feat/"* ]]
  [[ "$output" == /* ]]
}

@test "exits 1 when not in a ralph worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "exits 1 in a worktree without state.json" {
  local wt_path="$(bats_git_worktree 'feat/no-prd')"
  cd "$wt_path"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "accepts an explicit subpath argument" {
  local wt_path="$(bats_git_worktree 'feat/explicit')"
  mkdir -p "$wt_path/plans/feat_explicit"
  echo '{}' >"$wt_path/plans/feat_explicit/state.json"
  bats_run_zsh "$CURRENT" "$wt_path/plans/feat_explicit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/plans/feat_explicit/"* ]]
}
