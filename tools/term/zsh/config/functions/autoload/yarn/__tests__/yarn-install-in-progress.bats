bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
}

@test "returns 0 when the node lockfile exists" {
  export MOCK_LOCKFILE="$BATS_TMP_DIR/fake.lock"
  touch "$MOCK_LOCKFILE"

  git-dependencies-in-progress-lockfile() { REPLY="$MOCK_LOCKFILE"; }
  bats_mock git-dependencies-in-progress-lockfile

  bats_run_zsh "yarn-install-in-progress"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when the node lockfile does not exist" {
  export MOCK_LOCKFILE="$BATS_TMP_DIR/fake.lock"

  git-dependencies-in-progress-lockfile() { REPLY="$MOCK_LOCKFILE"; }
  bats_mock git-dependencies-in-progress-lockfile

  bats_run_zsh "yarn-install-in-progress"
  [[ "$status" -eq 1 ]]
}
