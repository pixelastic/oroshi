bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "exits 0 when plan-directory fails" {
  plan-directory() { return 1; }
  bats_mock plan-directory

  bats_run_zsh "$BATS_TEST_DIRNAME/../post-commit"
  [ "$status" -eq 0 ]
}

@test "exits 0 and deletes nothing when COMMIT_HINT.md is absent" {
  MOCK_PLAN_DIR="$BATS_TMP_DIR/plan"
  mkdir -p "$MOCK_PLAN_DIR"

  plan-directory() { echo "$MOCK_PLAN_DIR"; }
  bats_mock plan-directory

  bats_run_zsh "$BATS_TEST_DIRNAME/../post-commit"
  [ "$status" -eq 0 ]
  [ ! -f "$MOCK_PLAN_DIR/COMMIT_HINT.md" ]
}

@test "deletes COMMIT_HINT.md and exits 0 when it exists" {
  export MOCK_PLAN_DIR="$BATS_TMP_DIR/plan"
  mkdir -p "$MOCK_PLAN_DIR"
  touch "$MOCK_PLAN_DIR/COMMIT_HINT.md"

  plan-directory() { echo "$MOCK_PLAN_DIR"; }
  bats_mock plan-directory

  bats_run_zsh "$BATS_TEST_DIRNAME/../post-commit"
  [ "$status" -eq 0 ]
  [ ! -f "$MOCK_PLAN_DIR/COMMIT_HINT.md" ]
}
