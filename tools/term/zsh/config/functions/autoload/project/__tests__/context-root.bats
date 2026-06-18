bats_load_library 'helper'

setup() {
  bats_tmp_dir

  projects-load-definitions() { true; }
  project-path() { echo "project-path:$1"; }
  git-directory-root() { echo "git-directory-root:$1"; }
  bats_mock projects-load-definitions project-path git-directory-root
}

@test "in project: passes arg through project-name then to project-path" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "context-root /my/path"
  [ "$status" -eq 0 ]
  [ "$output" = "project-path:project-name:/my/path" ]
}

@test "in worktree: passes arg to git-directory-root" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 0; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "context-root /my/path"
  [ "$status" -eq 0 ]
  [ "$output" = "git-directory-root:/my/path" ]
}

@test "outside known project: returns empty" {
  project-name() { echo ""; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  bats_run_zsh "context-root /my/path"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "no arg: uses \$PWD" {
  project-name() { echo "project-name:$1"; }
  git-directory-is-worktree() { return 1; }
  bats_mock project-name git-directory-is-worktree
  cd "$BATS_TMP_DIR"
  bats_run_zsh "context-root"
  [ "$status" -eq 0 ]
  [ "$output" = "project-path:project-name:$BATS_TMP_DIR" ]
}
