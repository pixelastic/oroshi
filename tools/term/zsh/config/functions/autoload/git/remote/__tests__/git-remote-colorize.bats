bats_load_library 'helper'

setup() {
  bats_git_dir 'repo'
  CURRENT="$BATS_TEST_DIRNAME/../git-remote-colorize"
  cd "$BATS_GIT_DIR" || return
  git-remote-current() { echo 'origin'; }
  bats_mock git-remote-current
  git-remote-color() { echo '196'; }
  bats_mock git-remote-color
}

teardown() {
  bats_cleanup
}

# --- ANSI mode (no --zsh) ---

@test "git-remote-colorize origin produces ANSI output" {
  bats_run_zsh "$CURRENT" origin
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "git-remote-colorize origin ANSI output contains remote name" {
  bats_run_zsh "$CURRENT" origin
  [ "$status" -eq 0 ]
  [[ "$output" == *'origin'* ]]
}

@test "git-remote-colorize origin ANSI output contains no zsh codes" {
  bats_run_zsh "$CURRENT" origin
  [ "$status" -eq 0 ]
  [[ "$output" != *'%F{'* ]]
}

# --- Zsh mode (--zsh) ---

@test "git-remote-colorize origin --zsh produces zsh output" {
  bats_run_zsh "$CURRENT" origin --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-remote-colorize origin --zsh output contains remote name" {
  bats_run_zsh "$CURRENT" origin --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'origin'* ]]
}

@test "git-remote-colorize origin --zsh output contains no ANSI sequence" {
  bats_run_zsh "$CURRENT" origin --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}

# --- --with-icon --zsh ---

@test "git-remote-colorize --with-icon --zsh produces zsh output" {
  bats_run_zsh "$CURRENT" --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *'%F{'* ]]
}

@test "git-remote-colorize --with-icon --zsh output contains icon" {
  bats_run_zsh "$CURRENT" --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *' origin'* ]]
}

@test "git-remote-colorize --with-icon --zsh output contains no ANSI sequence" {
  bats_run_zsh "$CURRENT" --with-icon --zsh
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e['* ]]
}
