load '../../../../../../../../config/term/bats/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git branch -M main
  git checkout -b fix/bug
  git checkout main
  git commit --allow-empty -m "main work"
  git checkout fix/bug
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "rebases fix/bug on top of main" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-pull
  [ "$status" -eq 0 ]
}

@test "fix/bug contains main commits after pull" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-worktree-pull
  run git log --oneline
  [[ "$output" == *"main work"* ]]
}

@test "returns 1 if main does not exist" {
  git init "$TMP_DIRECTORY/no-main"
  cd "$TMP_DIRECTORY/no-main"
  git symbolic-ref HEAD refs/heads/develop
  git commit --allow-empty -m "init"
  git checkout -b fix/bug
  run_zsh_fn git-worktree-pull
  [ "$status" -ne 0 ]
}
