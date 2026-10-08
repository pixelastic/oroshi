bats_load_library 'helper'

setup() {
  bats_git_dir 'parent'
  export BATS_PARENT_DIR="$BATS_GIT_DIR"

  bats_git_submodule "$BATS_PARENT_DIR" 'sub'
}

@test "returns the superproject root inside a submodule" {
  bats_run_zsh "git-directory-superproject $BATS_PARENT_DIR/sub"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_PARENT_DIR" ]]
}

@test "defaults to the current directory" {
  bats_run_zsh "cd $BATS_PARENT_DIR/sub && git-directory-superproject"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$BATS_PARENT_DIR" ]]
}

@test "returns empty in a regular repo" {
  bats_run_zsh "git-directory-superproject $BATS_PARENT_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "returns empty outside any git repo" {
  bats_run_zsh "git-directory-superproject $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
