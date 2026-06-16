bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  mkdir -p "$BATS_GIT_DIR/plans/plan-a/issues"
  mkdir -p "$BATS_GIT_DIR/plans/plan-b"

  git-directory-root() { echo "$BATS_GIT_DIR"; }
  bats_mock git-directory-root

  export BATS_SEPARATOR="▮"
}

teardown() {
  bats_cleanup
}

@test "each line has format fullAbsolutePath▮basename" {
  bats_run_zsh "plan-list-raw"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "$BATS_GIT_DIR/plans/plan-a${BATS_SEPARATOR}plan-a" ]]
  [[ "${lines[1]}" == "$BATS_GIT_DIR/plans/plan-b${BATS_SEPARATOR}plan-b" ]]
}

@test "nested subdirectories do not appear" {
  bats_run_zsh "plan-list-raw"
  [ "$status" -eq 0 ]
  [[ "$output" != *"issues"* ]]
}

@test "exits 0 with no output when plans/ does not exist" {
  git-directory-root() { echo "$BATS_TMP_DIR/empty-repo"; }
  bats_mock git-directory-root
  mkdir -p "$BATS_TMP_DIR/empty-repo"

  bats_run_zsh "plan-list-raw"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
