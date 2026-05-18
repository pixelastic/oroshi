load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git commit --allow-empty -m "init"
  git branch -M main
  git checkout -b fix/bug
  git commit --allow-empty -m "fix work"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "fast-forwards main to current HEAD" {
  cd "$TMP_DIRECTORY/my-repo"
  local fixHead="$(git rev-parse HEAD)"
  run_zsh_fn git-worktree-push
  [ "$status" -eq 0 ]
  run git rev-parse main
  [ "$output" = "$fixHead" ]
}

@test "returns 1 if history has diverged" {
  git init "$TMP_DIRECTORY/diverged-repo"
  cd "$TMP_DIRECTORY/diverged-repo"
  git commit --allow-empty -m "init"
  git branch -M main
  git checkout -b fix/bug
  git commit --allow-empty -m "fix work"
  git checkout main
  git commit --allow-empty -m "main work"
  git checkout fix/bug
  run_zsh_fn git-worktree-push
  [ "$status" -ne 0 ]
}

