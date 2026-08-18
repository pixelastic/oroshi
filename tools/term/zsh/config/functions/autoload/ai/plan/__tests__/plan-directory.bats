bats_load_library 'helper'

# Mock context-slug as the only collaborator
_mock_defaults() {
  context-slug() { echo "repo--feat_my-feat"; }
  bats_mock context-slug
  bats_disable_worktree_aware
}

setup() {
  bats_tmp_dir
  export MOCK_OROSHI_PLANS_DIR="$BATS_TMP_DIR/plans"
  mkdir -p "$MOCK_OROSHI_PLANS_DIR"
}

@test "returns OROSHI_PLANS_DIR/<slug> from context-slug" {
  _mock_defaults
  bats_run_zsh "cd $BATS_TMP_DIR && plan-directory"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$MOCK_OROSHI_PLANS_DIR/repo--feat_my-feat" ]]
}

@test "exits 1 when context-slug fails" {
  context-slug() { return 1; }
  bats_mock context-slug
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && plan-directory"
  [[ "$status" -eq 1 ]]
}

@test "forwards --project flag to context-slug" {
  context-slug() {
    echo "$@" > "$BATS_TMP_DIR/args.txt"
    echo "myapp--feat_x"
  }
  bats_mock context-slug
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && plan-directory --project myapp"
  [[ "$(cat "$BATS_TMP_DIR/args.txt")" == *"--project myapp"* ]]
}

@test "forwards --branch flag to context-slug" {
  context-slug() {
    echo "$@" > "$BATS_TMP_DIR/args.txt"
    echo "repo--feat_x"
  }
  bats_mock context-slug
  bats_disable_worktree_aware
  bats_run_zsh "cd $BATS_TMP_DIR && plan-directory --branch feat/x"
  [[ "$(cat "$BATS_TMP_DIR/args.txt")" == *"--branch feat/x"* ]]
}

@test "forwards positional path arg to context-slug" {
  context-slug() {
    echo "$@" > "$BATS_TMP_DIR/args.txt"
    echo "repo--feat_x"
  }
  bats_mock context-slug
  bats_run_zsh "plan-directory /some/path"
  [[ "$(cat "$BATS_TMP_DIR/args.txt")" == *"/some/path"* ]]
}
