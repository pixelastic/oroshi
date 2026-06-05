bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-has-plan"
}

teardown() {
  bats_cleanup
}

@test "exits 0 inside a worktree with a plan" {
  local wt_path="$(bats_git_worktree 'feat/test-ralph')"
  mkdir -p "$wt_path/plans/feat_test-ralph"
  echo '{}' > "$wt_path/plans/feat_test-ralph/state.json"
  cd "$wt_path"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "exits 1 inside a worktree without a plan" {
  local wt_path="$(bats_git_worktree 'feat/no-prd')"
  cd "$wt_path"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "exits 1 outside any worktree" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}

@test "accepts an explicit path argument" {
  local wt_path="$(bats_git_worktree 'feat/explicit')"
  mkdir -p "$wt_path/plans/feat_explicit"
  echo '{}' > "$wt_path/plans/feat_explicit/state.json"
  bats_run_zsh "$CURRENT" "$wt_path"
  [ "$status" -eq 0 ]
}
