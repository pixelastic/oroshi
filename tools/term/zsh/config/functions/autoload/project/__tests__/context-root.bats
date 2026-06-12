bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../context-root"

  projects-load-definitions() { true; }
  bats_mock projects-load-definitions

  project-path() { echo "project-path:$1"; }
  bats_mock project-path

  git-directory-root() { echo "git-directory-root:$1"; }
  bats_mock git-directory-root
}

teardown() {
  bats_cleanup
}

@test "in project: passes arg through project-name then to project-path" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "$CURRENT" /my/path
  [ "$status" -eq 0 ]
  [ "$output" = "project-path:project-name:/my/path" ]
}

@test "in worktree: passes arg to git-directory-root" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 0; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "$CURRENT" /my/path
  [ "$status" -eq 0 ]
  [ "$output" = "git-directory-root:/my/path" ]
}

@test "outside known project: returns empty" {
  project-name() { echo ""; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "$CURRENT" /my/path
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "no arg: uses \$PWD" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  cd "$BATS_TMP_DIR"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "project-path:project-name:$BATS_TMP_DIR" ]
}
