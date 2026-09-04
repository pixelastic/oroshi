bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git checkout --quiet -b fix/bug
  bats_git checkout --quiet main
}

@test "returns 0 for existing local branch" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-exists main"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 for nonexistent branch" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-branch-exists nonexistent"
  [[ "$status" -eq 1 ]]
}

@test "supports --repo flag for existing branch" {
  bats_run_zsh "git-branch-exists --repo $BATS_GIT_DIR fix/bug"
  [[ "$status" -eq 0 ]]
}

@test "supports --repo flag for nonexistent branch" {
  bats_run_zsh "git-branch-exists --repo $BATS_GIT_DIR nonexistent"
  [[ "$status" -eq 1 ]]
}
