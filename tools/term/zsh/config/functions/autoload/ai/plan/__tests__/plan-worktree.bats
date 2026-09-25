bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Mocking OROSHI_WORKTREES_DIR defeats worktree detection, so lock the root
  bats_disable_worktree_aware
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR/repo--feat_my-feat"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/repo--feat_my-feat"
}

# Resolution

@test "prints the Worktree path for an existing Worktree" {
  bats_run_zsh "plan-worktree $MOCK_OROSHI_PLANS_DIR/repo--feat_my-feat"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$MOCK_OROSHI_WORKTREES_DIR/repo--feat_my-feat" ]]
}

@test "handles a plan directory with a trailing slash" {
  bats_run_zsh "plan-worktree $MOCK_OROSHI_PLANS_DIR/repo--feat_my-feat/"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$MOCK_OROSHI_WORKTREES_DIR/repo--feat_my-feat" ]]
}

# Failure

@test "returns 1 when the Worktree directory doesn't exist" {
  bats_run_zsh "plan-worktree $MOCK_OROSHI_PLANS_DIR/repo--feat_missing"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}

@test "returns 1 when no plan directory is given" {
  bats_run_zsh "plan-worktree"
  [[ "$status" -eq 1 ]]
  [[ "$output" == "" ]]
}
