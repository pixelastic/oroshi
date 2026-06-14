bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "colorizes tag name" {
  git-tag-current() { echo "v1.0"; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-tag-current colorize

  bats_run_zsh "git-tag-colorize v1.0"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "colorize:v1.0 "* ]]
}

@test "forwards --zsh flag to colorize" {
  git-tag-current() { echo "v1.0"; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-tag-current colorize

  bats_run_zsh "git-tag-colorize v1.0 --zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "colorize:v1.0 "*" --zsh" ]]
}

@test "--with-icon prepends tag-status icon to tag name" {
  git-tag-current() { echo "v1.0"; }
  git-tag-status() { echo "exact"; }
  colorize() { echo "colorize:$*"; }
  bats_mock git-tag-current git-tag-status colorize

  bats_run_zsh "git-tag-colorize v1.0 --with-icon --zsh"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *" v1.0 "*" --zsh" ]]
}
