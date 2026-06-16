bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "handles submodule in detached HEAD (no branch in status)" {
  git() { echo " abc12345678 some/module"; }
  git-directory-root() { echo "/repo"; }
  path-relative() { echo "$1"; }
  sort-filepaths() { echo "$@"; }
  git-submodule-colorize() { echo "$1"; }
  git-branch-colorize() { echo "$1"; }
  git-commit-colorize() { echo "$1"; }
  table() { echo "$1"; }
  bats_mock git git-directory-root path-relative sort-filepaths git-submodule-colorize git-branch-colorize git-commit-colorize table

  bats_run_zsh "git-submodule-list"

  [ "$status" -eq 0 ]
  [[ "$output" != *"substring expression"* ]]
}
