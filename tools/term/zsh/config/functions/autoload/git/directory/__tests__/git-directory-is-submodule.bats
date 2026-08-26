bats_load_library 'helper'

setup() {
  bats_git_dir 'parent'
  export BATS_PARENT_DIR="$BATS_GIT_DIR"

  bats_git_submodule "$BATS_PARENT_DIR" 'sub'
}

@test "returns 0 inside a submodule" {
  cd "$BATS_PARENT_DIR/sub"
  bats_run_zsh "git-directory-is-submodule"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 in a regular repo" {
  cd "$BATS_PARENT_DIR"
  bats_run_zsh "git-directory-is-submodule"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 outside any git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-directory-is-submodule"
  [[ "$status" -eq 1 ]]
}

@test "accepts an explicit path argument" {
  bats_run_zsh "git-directory-is-submodule $BATS_PARENT_DIR/sub"
  [[ "$status" -eq 0 ]]
}
