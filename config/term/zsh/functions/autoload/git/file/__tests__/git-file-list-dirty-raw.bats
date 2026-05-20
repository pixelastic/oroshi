bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "hello" > tracked.txt
  git add tracked.txt
  git commit -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns empty output for a clean repo" {
  cd "$TMP_DIRECTORY/my-repo"
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "lists untracked files as A" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "new" > untracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "A:untracked.txt" ]
}

@test "lists unstaged modified files as M" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "modified" > tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists unstaged deleted files as D" {
  cd "$TMP_DIRECTORY/my-repo"
  rm tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists staged new files as A" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "new" > staged.txt
  git add staged.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "A:staged.txt" ]
}

@test "lists staged modifications as M" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "modified" > tracked.txt
  git add tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "M:tracked.txt" ]
}

@test "lists staged deletions as D" {
  cd "$TMP_DIRECTORY/my-repo"
  git rm tracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "$output" = "D:tracked.txt" ]
}

@test "lists multiple dirty files" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "modified" > tracked.txt
  echo "new" > untracked.txt
  run_zsh_fn git-file-list-dirty-raw
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}
