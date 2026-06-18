bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
}

# --- no argument ---

@test "no arg: returns main on a fresh repo" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-branch-current"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "no arg: returns branch after checkout" {
  cd "$BATS_GIT_DIR"
  git checkout -b feat/hello
  bats_run_zsh "git-branch-current"
  [ "$status" -eq 0 ]
  [ "$output" = "feat/hello" ]
}

@test "no arg: fails outside a git repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-branch-current"
  [ "$status" -eq 1 ]
}

@test "no arg: returns HEAD in detached state" {
  cd "$BATS_GIT_DIR"
  local commit="$(git rev-parse HEAD)"
  git checkout --detach "$commit"
  bats_run_zsh "git-branch-current"
  [ "$status" -eq 0 ]
  [ "$output" = "HEAD" ]
}

# --- with path argument ---

@test "arg: returns branch of given repo path" {
  local other_repo
  other_repo="$(bats_git_dir 'other')"
  cd "$other_repo"
  git checkout -b fix/something
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-branch-current $other_repo"
  [ "$status" -eq 0 ]
  [ "$output" = "fix/something" ]
}

@test "arg: returns main of given repo while cwd is outside any repo" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "git-branch-current $BATS_GIT_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "arg: fails when given path is not a git repo" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-branch-current $BATS_TMP_DIR"
  [ "$status" -eq 1 ]
}
