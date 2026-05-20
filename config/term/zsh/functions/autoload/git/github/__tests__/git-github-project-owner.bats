bats_load_library 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/testrepo"
  git -C "$TMP_DIRECTORY/testrepo" commit --allow-empty -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns owner from SSH GitHub URL" {
  git -C "$TMP_DIRECTORY/testrepo" remote add origin git@github.com:pixelastic/testrepo.git
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project-owner
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic" ]
}

@test "returns owner from HTTPS GitHub URL" {
  git -C "$TMP_DIRECTORY/testrepo" remote add origin https://github.com/pixelastic/testrepo.git
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project-owner
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic" ]
}

@test "returns 1 when no remote" {
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project-owner
  [ "$status" -eq 1 ]
}
