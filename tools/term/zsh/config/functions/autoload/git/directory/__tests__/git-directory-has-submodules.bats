bats_load_library 'helper'

setup() {
  bats_git_dir 'parent'
}

@test "returns 0 when repo has submodules" {
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'

  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-has-submodules"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when repo has no submodules" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-directory-has-submodules"
  [[ "$status" -eq 1 ]]
}

@test "accepts an explicit path argument" {
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'

  bats_run_zsh "git-directory-has-submodules $BATS_GIT_DIR"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 for explicit path without submodules" {
  bats_run_zsh "git-directory-has-submodules $BATS_GIT_DIR"
  [[ "$status" -eq 1 ]]
}
