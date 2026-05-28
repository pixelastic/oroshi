bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  cd "$BATS_GIT_DIR"
  git-tag-current() { echo 'v1.0'; }
  bats_mock git-tag-current
  git-tag-status() { echo 'exact'; }
  bats_mock git-tag-status
}

teardown() {
  bats_cleanup
}

# --- ANSI mode (no --zsh) ---

@test "git-tag-colorize v1.0 produces ANSI output" {
  bats_run_function git-tag-colorize v1.0
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "git-tag-colorize v1.0 ANSI output contains tag name" {
  bats_run_function git-tag-colorize v1.0
  [ "$status" -eq 0 ]
  [[ "$output" == *'v1.0'* ]]
}

@test "git-tag-colorize v1.0 ANSI output contains no zsh codes" {
  bats_run_function git-tag-colorize v1.0
  [ "$status" -eq 0 ]
  [[ "$output" != *'%F{'* ]]
}

# --- Zsh mode (--zsh) ---

@test "git-tag-colorize v1.0 --zsh produces zsh output" {
  bats_run_function git-tag-colorize v1.0 --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-tag-colorize v1.0 --zsh output contains tag name" {
  bats_run_function git-tag-colorize v1.0 --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'v1.0'* ]]
}

@test "git-tag-colorize v1.0 --zsh output contains no ANSI sequence" {
  bats_run_function git-tag-colorize v1.0 --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}

# --- --with-icon --zsh ---

@test "git-tag-colorize --with-icon --zsh produces zsh output" {
  bats_run_function git-tag-colorize --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-tag-colorize --with-icon --zsh output contains icon" {
  bats_run_function git-tag-colorize --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *' v1.0'* ]]
}

@test "git-tag-colorize --with-icon --zsh output contains no ANSI sequence" {
  bats_run_function git-tag-colorize --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}
