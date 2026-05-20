bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$TMP_DIRECTORY/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "GIT_DIRECTORY_IS_WORKTREE is 1 inside a linked worktree" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run zsh -c '
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/index.zsh
    oroshi-git-env-store
    echo "$GIT_DIRECTORY_IS_WORKTREE"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "GIT_DIRECTORY_IS_WORKTREE is 0 in the Git Repo Main" {
  cd "$TMP_DIRECTORY/my-repo"
  run zsh -c '
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/index.zsh
    oroshi-git-env-store
    echo "$GIT_DIRECTORY_IS_WORKTREE"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}
