bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  cd "$BATS_GIT_DIR"
  git-branch-color() { echo 87; }
  bats_mock git-branch-color
  git-branch-push-status() { echo 'never_pushed'; }
  bats_mock git-branch-push-status
}

teardown() {
  bats_cleanup
}

# --- ANSI mode (no --zsh) ---

@test "git-branch-colorize main produces ANSI output" {
  bats_run_function git-branch-colorize main
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "git-branch-colorize main ANSI output contains branch name" {
  bats_run_function git-branch-colorize main
  [ "$status" -eq 0 ]
  [[ "$output" == *'main'* ]]
}

@test "git-branch-colorize main ANSI output contains no zsh codes" {
  bats_run_function git-branch-colorize main
  [ "$status" -eq 0 ]
  [[ "$output" != *'%F{'* ]]
}

# --- Zsh mode (--zsh) ---

@test "git-branch-colorize main --zsh produces zsh output" {
  bats_run_function git-branch-colorize main --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-branch-colorize main --zsh output contains branch name" {
  bats_run_function git-branch-colorize main --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'main'* ]]
}

@test "git-branch-colorize main --zsh output contains no ANSI sequence" {
  bats_run_function git-branch-colorize main --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}

# --- --with-icon --zsh ---

@test "git-branch-colorize --with-icon --zsh produces zsh output" {
  bats_run_function git-branch-colorize main --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-branch-colorize --with-icon --zsh output contains icon" {
  bats_run_function git-branch-colorize main --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *' main'* ]]
}

@test "git-branch-colorize --with-icon --zsh output contains no ANSI sequence" {
  bats_run_function git-branch-colorize main --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}
