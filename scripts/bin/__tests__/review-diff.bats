load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  export PATH="${BATS_TEST_DIRNAME}/../ai:$PATH"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "initial content" > tracked.txt
  git add tracked.txt
  git commit --message "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "0-arg, clean tree: exits 0 with empty output" {
  cd "$TMP_DIRECTORY/my-repo"
  run review-diff
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "0-arg, modified tracked file: stdout contains diff hunk" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "modified content" >> tracked.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"modified content"* ]]
}

@test "0-arg, untracked file: stdout contains new-file diff block" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "new file content" > new-file.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"new file mode"* ]]
}

@test "0-arg, staged file: stdout contains staged hunk" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "staged content" >> tracked.txt
  git add tracked.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"staged content"* ]]
}

@test "1-arg branch, self-review: stdout contains feature commit and diff --git line" {
  cd "$TMP_DIRECTORY/my-repo"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"

  run review-diff feature-branch
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add feature.txt"* ]]
  [[ "$output" == *"diff --git"* ]]
}

@test "1-arg SHA: stdout contains the commit message and a diff --git line" {
  cd "$TMP_DIRECTORY/my-repo"
  echo "sha content" > sha-file.txt
  git add sha-file.txt
  git commit --message "feat: add sha-file.txt"
  local sha
  sha="$(git rev-parse HEAD)"

  run review-diff "$sha"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add sha-file.txt"* ]]
  [[ "$output" == *"diff --git"* ]]
}

@test "1-arg branch, external review: stdout contains feature commit; main-only commits absent" {
  cd "$TMP_DIRECTORY/my-repo"
  local mainBranch="$(git branch --show-current)"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"
  git checkout "$mainBranch"
  echo "main content" > main-only.txt
  git add main-only.txt
  git commit --message "main: main-only commit"

  run review-diff feature-branch
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add feature.txt"* ]]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" != *"main: main-only commit"* ]]
}
