bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "skips dependency update with --no-dependencies" {
  git() {
    [[ "$*" == *"cat-file"* ]] && echo "commit" && return 0
    echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"
  }
  git-dependencies-update() { echo "called" > "$BATS_TMP_DIR/deps-called.txt"; }
  bats_mock git git-dependencies-update

  bats_run_zsh "git-branch-switch --no-dependencies main"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/deps-called.txt" ]]
}

@test "calls dependency update without --no-dependencies" {
  git() {
    [[ "$*" == *"cat-file"* ]] && echo "commit" && return 0
    return 0
  }
  git-commit-current() { echo "abc1234"; }
  git-dependencies-update() { echo "called" > "$BATS_TMP_DIR/deps-called.txt"; }
  bats_mock git git-commit-current git-dependencies-update

  bats_run_zsh "git-branch-switch main"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/deps-called.txt" ]]
}

@test "passes -C to git when --repo is set" {
  git() {
    echo "$@" >> "$BATS_TMP_DIR/git-calls.txt"
    [[ "$*" == *"cat-file"* ]] && echo "commit" && return 0
    return 0
  }
  bats_mock git

  bats_run_zsh "git-branch-switch --no-dependencies --repo /my/repo develop"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/git-calls.txt")"
  [[ "$calls" == *"-C /my/repo cat-file"* ]]
  [[ "$calls" == *"-C /my/repo checkout --quiet develop"* ]]
}
