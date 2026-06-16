bats_load_library 'helper'

setup() {
  bats_git_dir 'testrepo'
}

teardown() {
  bats_cleanup
}

@test "returns owner from SSH GitHub URL" {
  bats_git remote add origin git@github.com:pixelastic/testrepo.git
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-github-project-owner"
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic" ]
}

@test "returns owner from HTTPS GitHub URL" {
  bats_git remote add origin https://github.com/pixelastic/testrepo.git
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-github-project-owner"
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic" ]
}

@test "returns 1 when no remote" {
  cd "$BATS_GIT_DIR"
  bats_run_zsh "git-github-project-owner"
  [ "$status" -eq 1 ]
}
