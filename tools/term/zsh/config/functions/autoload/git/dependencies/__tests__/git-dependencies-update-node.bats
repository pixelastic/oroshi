bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# --- --repo propagation ---

@test "--repo is passed to git-directory-root" {
  git-directory-root() {
    echo "$@" > "$BATS_TMP_DIR/dir-root-args.txt"
    echo "$BATS_TMP_DIR/fake-repo"
  }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() { return 0; }
  fork() { :; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123 --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/dir-root-args.txt")" == "/some/repo" ]]
}

@test "--repo is passed to git-dependencies-in-progress-lockfile" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() {
    echo "$@" > "$BATS_TMP_DIR/lockfile-args.txt"
    echo "/tmp/lockfile"
  }
  git-file-has-changed() { return 0; }
  fork() { :; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123 --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/lockfile-args.txt")" == *"--repo /some/repo"* ]]
}

@test "--repo is passed to git-file-has-changed" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() {
    echo "$@" > "$BATS_TMP_DIR/changed-args.txt"
    return 0
  }
  fork() { :; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123 --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/changed-args.txt")" == *"--repo /some/repo"* ]]
}

# --- No origin commit ---

@test "no commit + beacon exists → runs unconditionally" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  fork() {
    echo "forked" > "$BATS_TMP_DIR/fork-called.txt"
  }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/fork-called.txt" ]]
}

@test "no commit + beacon missing → returns early" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  fork() {
    echo "forked" > "$BATS_TMP_DIR/fork-called.txt"
  }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"

  bats_run_zsh "git-dependencies-update-node"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/fork-called.txt" ]]
}

# --- Lockfile path ---

@test "uses git-dependencies-in-progress-lockfile for lockfile path" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/custom/lockfile/path"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$2" > "$BATS_TMP_DIR/fork-lockfile.txt"
  }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-lockfile.txt")" == "/custom/lockfile/path" ]]
}

# --- fork cd prefix ---

@test "fork command includes cd prefix when --repo is set" {
  git-directory-root() { echo "$BATS_TMP_DIR/target-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$1" > "$BATS_TMP_DIR/fork-cmd.txt"
  }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/target-repo"
  touch "$BATS_TMP_DIR/target-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123 --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-cmd.txt")" == "cd $BATS_TMP_DIR/target-repo && yarn install" ]]
}

@test "fork command uses default repo when --repo is not provided" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$1" > "$BATS_TMP_DIR/fork-cmd.txt"
  }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/yarn.lock"

  bats_run_zsh "git-dependencies-update-node abc123"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-cmd.txt")" == "cd $BATS_TMP_DIR/fake-repo && yarn install" ]]
}
