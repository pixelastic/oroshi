bats_load_library 'helper'

setup() {
  bats_git_dir 'testrepo'
  CURRENT="$BATS_TEST_DIRNAME/../git-github-project-name"
}

teardown() {
  bats_cleanup
}

@test "returns repo name from SSH GitHub URL" {
  bats_git remote add origin git@github.com:pixelastic/testrepo.git
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "testrepo" ]
}

@test "returns repo name from HTTPS GitHub URL" {
  bats_git remote add origin https://github.com/pixelastic/testrepo.git
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "testrepo" ]
}

@test "returns 1 when no remote" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
}
