load '../../../../../../../../config/term/bats/helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/testrepo"
  git -C "$TMP_DIRECTORY/testrepo" commit --allow-empty -m "init"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "returns owner/name from SSH GitHub URL" {
  git -C "$TMP_DIRECTORY/testrepo" remote add origin git@github.com:pixelastic/testrepo.git
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic/testrepo" ]
}

@test "returns owner/name from HTTPS GitHub URL" {
  git -C "$TMP_DIRECTORY/testrepo" remote add origin https://github.com/pixelastic/testrepo.git
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project
  [ "$status" -eq 0 ]
  [ "$output" = "pixelastic/testrepo" ]
}

@test "returns 1 when no remote" {
  cd "$TMP_DIRECTORY/testrepo"
  run_zsh_fn git-github-project
  [ "$status" -eq 1 ]
}
