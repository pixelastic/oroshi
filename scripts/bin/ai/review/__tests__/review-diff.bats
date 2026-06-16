bats_load_library 'helper'

setup() {
  export PATH="${BATS_TEST_DIRNAME}/../ai:$PATH"
  bats_git_dir 'my-repo'
  echo "initial content" > "$BATS_GIT_DIR/tracked.txt"
  bats_git add tracked.txt
  bats_git commit --quiet --message "add tracked"
}

teardown() {
  bats_cleanup
}

@test "0-arg, clean tree: exits 0 with empty output" {
  cd "$BATS_GIT_DIR"
  run review-diff
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "0-arg, modified tracked file: stdout contains diff hunk" {
  cd "$BATS_GIT_DIR"
  echo "modified content" >> tracked.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"modified content"* ]]
}

@test "0-arg, untracked file: stdout contains new-file diff block" {
  cd "$BATS_GIT_DIR"
  echo "new file content" > new-file.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"new file mode"* ]]
}

@test "0-arg, untracked file: diff paths are relative to repo root, not absolute" {
  cd "$BATS_GIT_DIR"
  mkdir -p subdir
  echo "new file content" > subdir/new-file.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" != *"$BATS_GIT_DIR"* ]]
  [[ "$output" == *"subdir/new-file.txt"* ]]
}

@test "0-arg, staged file: stdout contains staged hunk" {
  cd "$BATS_GIT_DIR"
  echo "staged content" >> tracked.txt
  git add tracked.txt
  run review-diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"staged content"* ]]
}

@test "1-arg branch, self-review: stdout contains feature commit and diff --git line" {
  cd "$BATS_GIT_DIR"
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
  cd "$BATS_GIT_DIR"
  echo "sha content" > sha-file.txt
  git add sha-file.txt
  git commit --message "feat: add sha-file.txt"
  local sha="$(git rev-parse HEAD)"

  run review-diff "$sha"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add sha-file.txt"* ]]
  [[ "$output" == *"diff --git"* ]]
}

@test "1-arg dotdot range: stdout contains range commits and diff --git line; out-of-range commits absent" {
  cd "$BATS_GIT_DIR"
  local shaA="$(git rev-parse HEAD)"
  echo "main content" > main-only.txt
  git add main-only.txt
  git commit --message "main: commit B"
  git checkout -b feature-branch "$shaA"
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: commit C"

  run review-diff "$shaA..feature-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: commit C"* ]]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" != *"main: commit B"* ]]
}

@test "1-arg worktree: shows all commits and diff since worktree was created" {
  bats_git_worktree 'fix/bug'
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"

  run review-diff worktree
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add feature.txt"* ]]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" != *"add tracked"* ]]
}

@test "1-arg branch, external review from feature branch: feature content added (+), base-only commits absent" {
  cd "$BATS_GIT_DIR"
  local mainBranch="$(git branch --show-current)"
  git checkout -b feature-branch
  echo "feature content" > feature.txt
  git add feature.txt
  git commit --message "feat: add feature.txt"

  run review-diff "$mainBranch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat: add feature.txt"* ]]
  [[ "$output" == *"+feature content"* ]]
  [[ "$output" != *"-feature content"* ]]
}

@test "1-arg dirty, clean tree: exits 0 with empty output" {
  cd "$BATS_GIT_DIR"
  run review-diff dirty
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "1-arg dirty, modified tracked file: stdout contains diff hunk" {
  cd "$BATS_GIT_DIR"
  echo "modified content" >> tracked.txt
  run review-diff dirty
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"modified content"* ]]
}

@test "1-arg dirty, untracked file: stdout contains new-file diff block" {
  cd "$BATS_GIT_DIR"
  echo "new file content" > new-file.txt
  run review-diff dirty
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
  [[ "$output" == *"new file mode"* ]]
}

@test "1-arg branch, external review: stdout contains feature commit; main-only commits absent" {
  cd "$BATS_GIT_DIR"
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
