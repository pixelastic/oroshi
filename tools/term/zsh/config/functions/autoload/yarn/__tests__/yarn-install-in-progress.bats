bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  export MOCK_LOCKFILE="$BATS_TMP_DIR/fake.lock"
  git-dependencies-in-progress-lockfile() { REPLY="$MOCK_LOCKFILE"; }
  bats_mock git-dependencies-in-progress-lockfile
}

@test "returns 0 when the node lockfile is held by a live process" {
  lockfile-is-active() { return 0; }
  bats_mock lockfile-is-active

  bats_run_zsh "yarn-install-in-progress"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when the node lockfile is not held by a live process" {
  lockfile-is-active() { return 1; }
  bats_mock lockfile-is-active

  bats_run_zsh "yarn-install-in-progress"
  [[ "$status" -eq 1 ]]
}

@test "checks the node lockfile path" {
  lockfile-is-active() {
    echo "$1" > "$BATS_TMP_DIR/checked-path"
    return 0
  }
  bats_mock lockfile-is-active

  bats_run_zsh "yarn-install-in-progress"
  [[ "$(<"$BATS_TMP_DIR/checked-path")" == "$MOCK_LOCKFILE" ]]
}
