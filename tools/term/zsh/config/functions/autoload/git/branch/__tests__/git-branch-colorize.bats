bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "colorizes branch name" {
  git-branch-color() { echo 87; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-branch-color colorize

  bats_run_zsh "git-branch-colorize main"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "colorize:main 87" ]]
}

@test "forwards --zsh flag to colorize" {
  git-branch-color() { echo 87; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-branch-color colorize

  bats_run_zsh "git-branch-colorize main --zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "colorize:main 87 --zsh" ]]
}

@test "--with-icon prepends push-status icon to branch name" {
  git-branch-color() { echo 87; }
  git-branch-push-status() { echo "never_pushed"; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-branch-color git-branch-push-status colorize

  bats_run_zsh "git-branch-colorize main --with-icon --zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *" main 87 --zsh" ]]
}
