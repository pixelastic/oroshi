bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR"
}

@test "exits 0 when ralph.json exists in external plan dir" {
  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/repo--feat_test"; }
  bats_mock plan-directory
  bats_disable_worktree_aware
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/repo--feat_test"
  echo '{}' > "$MOCK_OROSHI_PLANS_DIR/repo--feat_test/ralph.json"
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-is-running"
  [[ "$status" -eq 0 ]]
}

@test "exits 1 when no ralph.json in external plan dir" {
  plan-directory() { echo "$MOCK_OROSHI_PLANS_DIR/repo--feat_test"; }
  bats_mock plan-directory
  bats_disable_worktree_aware
  mkdir -p "$MOCK_OROSHI_PLANS_DIR/repo--feat_test"
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-is-running"
  [[ "$status" -eq 1 ]]
}

@test "exits 1 when plan-directory fails" {
  plan-directory() { return 1; }
  bats_mock plan-directory
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && ralph-is-running"
  [[ "$status" -eq 1 ]]
}
