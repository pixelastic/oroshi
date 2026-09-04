bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "runs submodule update in given directory" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  git-submodule-list-raw() { return 0; }
  bats_mock git git-submodule-list-raw

  bats_run_zsh "git-submodule-update-all $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == *"-C"* ]]
  [[ "$args" == *"$BATS_TMP_DIR"* ]]
  [[ "$args" == *"submodule update"* ]]
}

@test "defaults to current directory" {
  git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
  git-submodule-list-raw() { return 0; }
  bats_mock git git-submodule-list-raw
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && git-submodule-update-all"
  [[ "$status" -eq 0 ]]

  local args="$(cat "$BATS_TMP_DIR/git-args.txt")"
  [[ "$args" == "-C . submodule update" ]]
}

@test "checks out the branch configured in .gitmodules" {
  git() { return 0; }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "develop"; }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/private develop"* ]]
}

@test "falls back to main when no branch configured in .gitmodules" {
  git() { return 0; }
  git-submodule-list-raw() { echo "private▮abc12345▮"; }
  git-submodule-branch() { echo "main"; }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/private main"* ]]
}

@test "checks out each submodule on its own configured branch" {
  git() { return 0; }
  git-submodule-list-raw() {
    printf 'alpha▮aaa12345▮\nbeta▮bbb98765▮\n'
  }
  git-submodule-branch() {
    [[ "$*" == *"alpha" ]] && echo "develop" && return 0
    [[ "$*" == *"beta" ]] && echo "release" && return 0
  }
  git-branch-switch() { echo "$@" >> "$BATS_TMP_DIR/switch-calls.txt"; }
  bats_mock git git-submodule-list-raw git-submodule-branch git-branch-switch

  bats_run_zsh "git-submodule-update-all /repo"
  [[ "$status" -eq 0 ]]

  local calls="$(cat "$BATS_TMP_DIR/switch-calls.txt")"
  [[ "$calls" == *"--no-dependencies --repo /repo/alpha develop"* ]]
  [[ "$calls" == *"--no-dependencies --repo /repo/beta release"* ]]
}
