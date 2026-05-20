load '../../../../../../../../config/term/bats/helper'

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

@test "returns project name when worktree main is a registered project" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run zsh -c "PROJECTS_INDEX_BY_PATH=MYKEY; PROJECT_MYKEY_PATH=${TMP_DIRECTORY}/my-repo/; PROJECT_MYKEY_NAME=my-project; git-worktree-project"
  [ "$status" -eq 0 ]
  [ "$output" = "my-project" ]
}

@test "returns empty string when worktree main is not a registered project" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run zsh -c "PROJECTS_INDEX_BY_PATH=; git-worktree-project"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
