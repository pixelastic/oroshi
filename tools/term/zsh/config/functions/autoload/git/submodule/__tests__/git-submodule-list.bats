bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "handles submodule in detached HEAD (no branch in status)" {
  git-submodule-list-raw() { echo "some/module▮abc12345▮"; }
  git-submodule-colorize() { echo "$1"; }
  git-branch-colorize() { echo "$1"; }
  git-commit-colorize() { echo "$1"; }
  table() { echo "$1"; }
  bats_mock git-submodule-list-raw git-submodule-colorize git-branch-colorize git-commit-colorize table

  bats_run_zsh "git-submodule-list"

  [[ "$status" -eq 0 ]]
  [[ "$output" != *"substring expression"* ]]
}
