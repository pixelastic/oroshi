bats_load_library 'helper'

setup() {
  bats_git_dir 'test-repo'
  echo "a" > "$BATS_GIT_DIR/a.txt"
  mkdir -p "$BATS_GIT_DIR/sub"
  echo "c" > "$BATS_GIT_DIR/sub/c.txt"
  bats_git add .
  bats_git commit --quiet --message "initial"
}

# --- Committed file ---

@test "returns 0 for a committed file" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file a.txt"
  [[ "$status" -eq 0 ]]
}

@test "returns 0 for a file in a subdirectory" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file sub/c.txt"
  [[ "$status" -eq 0 ]]
}

# --- Untracked file ---

@test "returns 1 for an untracked file" {
  echo "new" > "$BATS_GIT_DIR/new.txt"
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file new.txt"
  [[ "$status" -eq 1 ]]
}

# --- Custom commit ---

@test "checks against a specific commit" {
  local firstCommit="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
  echo "d" > "$BATS_GIT_DIR/d.txt"
  bats_git add d.txt
  bats_git commit --quiet --message "add d"

  # d.txt exists in HEAD but not in firstCommit
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file --commit $firstCommit d.txt"
  [[ "$status" -eq 1 ]]

  # a.txt exists in firstCommit
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file --commit $firstCommit a.txt"
  [[ "$status" -eq 0 ]]
}

# --- Custom repo ---

@test "checks against a different repo" {
  bats_run_zsh "git-commit-has-file --repo $BATS_GIT_DIR a.txt"
  [[ "$status" -eq 0 ]]
}

@test "fails for untracked file in a different repo" {
  echo "new" > "$BATS_GIT_DIR/new.txt"
  bats_run_zsh "git-commit-has-file --repo $BATS_GIT_DIR new.txt"
  [[ "$status" -eq 1 ]]
}

# --- No argument ---

@test "returns 1 when no file given" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-commit-has-file"
  [[ "$status" -eq 1 ]]
}
