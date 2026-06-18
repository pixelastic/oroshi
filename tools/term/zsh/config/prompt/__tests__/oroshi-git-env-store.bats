bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '$BATS_TEST_DIRNAME/../oroshi-git-env-store.zsh'"
}

@test "GIT_DIRECTORY_IS_WORKTREE is 1 when in a linked worktree" {
  git-directory-is-worktree() { return 0; }
  git-directory-is-repository() { return 0; }
  bats_mock git-directory-is-worktree git-directory-is-repository

  bats_run_zsh "$sourcePrefix && oroshi-git-env-store && echo \$GIT_DIRECTORY_IS_WORKTREE"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "GIT_DIRECTORY_IS_WORKTREE is 0 when not in a linked worktree" {
  git-directory-is-worktree() { return 1; }
  git-directory-is-repository() { return 0; }
  bats_mock git-directory-is-worktree git-directory-is-repository

  bats_run_zsh "$sourcePrefix && oroshi-git-env-store && echo \$GIT_DIRECTORY_IS_WORKTREE"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}
