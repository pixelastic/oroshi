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
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --repo /some/repo --async"
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
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --repo /some/repo --async"
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
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --repo /some/repo --async"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/changed-args.txt")" == *"--repo /some/repo"* ]]
}

# --- No origin commit ---

@test "no commit + beacon exists → runs synchronously by default" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  # bundle install will fail (no Gemfile content) but eval is still called
  bats_run_zsh "git-dependencies-update-ruby"
  [[ "$output" == *"bundle"* ]] || [[ "$status" -ne 0 ]]
}

@test "no commit + beacon exists + --async → forks" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  fork() {
    echo "forked" > "$BATS_TMP_DIR/fork-called.txt"
  }
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby --async"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/fork-called.txt" ]]
}

@test "no commit + beacon missing → returns early" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  fork() {
    echo "forked" > "$BATS_TMP_DIR/fork-called.txt"
  }
  glob() { echo ""; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"

  bats_run_zsh "git-dependencies-update-ruby --async"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/fork-called.txt" ]]
}

# --- Lockfile path (async mode) ---

@test "uses git-dependencies-in-progress-lockfile for lockfile path" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/custom/lockfile/path"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$2" > "$BATS_TMP_DIR/fork-lockfile.txt"
  }
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --async"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-lockfile.txt")" == "/custom/lockfile/path" ]]
}

# --- fork cd prefix (async mode) ---

@test "fork command includes cd prefix when --repo is set" {
  git-directory-root() { echo "$BATS_TMP_DIR/target-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$1" > "$BATS_TMP_DIR/fork-cmd.txt"
  }
  glob() { echo "$BATS_TMP_DIR/target-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/target-repo"
  touch "$BATS_TMP_DIR/target-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --repo /some/repo --async"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-cmd.txt")" == "cd $BATS_TMP_DIR/target-repo && bundle install" ]]
}

@test "fork command uses default repo when --repo is not provided" {
  git-directory-root() { echo "$BATS_TMP_DIR/fake-repo"; }
  git-dependencies-in-progress-lockfile() { echo "/tmp/lockfile"; }
  git-file-has-changed() { return 0; }
  fork() {
    echo "$1" > "$BATS_TMP_DIR/fork-cmd.txt"
  }
  glob() { echo "$BATS_TMP_DIR/fake-repo/Gemfile"; }
  bats_mock git-directory-root git-dependencies-in-progress-lockfile git-file-has-changed fork glob

  mkdir -p "$BATS_TMP_DIR/fake-repo"
  touch "$BATS_TMP_DIR/fake-repo/Gemfile"

  bats_run_zsh "git-dependencies-update-ruby abc123 --async"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/fork-cmd.txt")" == "cd $BATS_TMP_DIR/fake-repo && bundle install" ]]
}
