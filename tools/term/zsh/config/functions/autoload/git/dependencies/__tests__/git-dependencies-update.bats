bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "passes --repo to git-submodule-update-all" {
  git-submodule-update-all() {
    echo "$@" > "$BATS_TMP_DIR/submodule-args.txt"
  }
  git-dependencies-update-node() { :; }
  git-dependencies-update-ruby() { :; }
  bats_mock git-submodule-update-all git-dependencies-update-node git-dependencies-update-ruby

  bats_run_zsh "git-dependencies-update --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/submodule-args.txt")" == "/some/repo" ]]
}

@test "passes --repo to both language updaters" {
  git-submodule-update-all() { :; }
  git-dependencies-update-node() {
    echo "$@" > "$BATS_TMP_DIR/node-args.txt"
  }
  git-dependencies-update-ruby() {
    echo "$@" > "$BATS_TMP_DIR/ruby-args.txt"
  }
  bats_mock git-submodule-update-all git-dependencies-update-node git-dependencies-update-ruby

  bats_run_zsh "git-dependencies-update abc123 --repo /some/repo"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args.txt")" == *"--repo /some/repo"* ]]
  [[ "$(cat "$BATS_TMP_DIR/ruby-args.txt")" == *"--repo /some/repo"* ]]
}

@test "passes origin commit to language updaters" {
  git-submodule-update-all() { :; }
  git-dependencies-update-node() {
    echo "$@" > "$BATS_TMP_DIR/node-args.txt"
  }
  git-dependencies-update-ruby() {
    echo "$@" > "$BATS_TMP_DIR/ruby-args.txt"
  }
  bats_mock git-submodule-update-all git-dependencies-update-node git-dependencies-update-ruby

  bats_run_zsh "git-dependencies-update abc123"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args.txt")" == *"abc123"* ]]
  [[ "$(cat "$BATS_TMP_DIR/ruby-args.txt")" == *"abc123"* ]]
}

@test "defaults to current repo when --repo is not provided" {
  git-directory-root() { echo "/resolved/current/repo"; }
  git-submodule-update-all() {
    echo "$@" > "$BATS_TMP_DIR/submodule-args.txt"
  }
  git-dependencies-update-node() {
    echo "$@" > "$BATS_TMP_DIR/node-args.txt"
  }
  git-dependencies-update-ruby() { :; }
  bats_mock git-directory-root git-submodule-update-all git-dependencies-update-node git-dependencies-update-ruby

  bats_run_zsh "git-dependencies-update abc123"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/submodule-args.txt")" == "/resolved/current/repo" ]]
  [[ "$(cat "$BATS_TMP_DIR/node-args.txt")" == *"--repo /resolved/current/repo"* ]]
}

@test "uses git-submodule-update-all instead of bare git submodule update" {
  git-submodule-update-all() {
    echo "called" > "$BATS_TMP_DIR/submodule-called.txt"
  }
  git-dependencies-update-node() { :; }
  git-dependencies-update-ruby() { :; }
  bats_mock git-submodule-update-all git-dependencies-update-node git-dependencies-update-ruby

  bats_run_zsh "git-dependencies-update"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/submodule-called.txt" ]]
}
