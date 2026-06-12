bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-directory-root"
}

teardown() {
  bats_cleanup
}

# --- no argument ---

@test "no arg: returns repo root from repo root" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "no arg: returns repo root from a subdir" {
  mkdir -p "$BATS_GIT_DIR/sub/dir"
  cd "$BATS_GIT_DIR/sub/dir"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "no arg: outside repo, returns PWD and exits 1" {
  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [ "$output" = "$BATS_TMP_DIR" ]
}

# --- with path argument ---

@test "arg is a subdir of current repo: returns repo root" {
  mkdir -p "$BATS_GIT_DIR/sub/dir"
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "$BATS_GIT_DIR/sub/dir"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "arg path contains .git/: returns repo root" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" "$BATS_GIT_DIR/.git/config"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "arg is a path in a different repo: returns that repo's root" {
  local primary_repo="$BATS_GIT_DIR"
  local other_repo
  other_repo="$(bats_git_dir 'other')"
  cd "$primary_repo"
  bats_run_zsh "$CURRENT" "$other_repo"
  [ "$status" -eq 0 ]
  [ "$output" = "$other_repo" ]
}

@test "arg is a file path: returns the repo root (not a garbled path)" {
  touch "$BATS_GIT_DIR/some-file.lua"
  bats_run_zsh "$CURRENT" "$BATS_GIT_DIR/some-file.lua"
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

# --- flags ---

@test "-f flag: returns repo root when no superproject" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" -f
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}

@test "--force flag: returns repo root when no superproject" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT" --force
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_GIT_DIR" ]
}
