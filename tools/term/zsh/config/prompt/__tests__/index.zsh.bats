bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

@test "GIT_DIRECTORY_IS_WORKTREE is 1 inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c '
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source ~/.oroshi/tools/term/zsh/config/prompt/index.zsh
    oroshi-git-env-store
    echo "$GIT_DIRECTORY_IS_WORKTREE"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "git_worktree_branch is not in OROSHI_ASYNCHRONOUS_PROMPT_PARTS" {
  run grep 'git_worktree_branch' "$OROSHI_ROOT/config/term/zsh/prompt/index.zsh"
  [ "$status" -eq 1 ]
}

@test "GIT_DIRECTORY_IS_WORKTREE is 0 in the Git Repo Main" {
  cd "$BATS_GIT_DIR"
  run zsh -c '
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source ~/.oroshi/tools/term/zsh/config/prompt/index.zsh
    oroshi-git-env-store
    echo "$GIT_DIRECTORY_IS_WORKTREE"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}
