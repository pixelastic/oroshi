bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "replaces single slash with underscore" {
  bats_run_function git-branch-slug "feat/my-feature"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_my-feature" ]
}

@test "replaces multiple slashes with underscores" {
  bats_run_function git-branch-slug "feat/scope/deep"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_scope_deep" ]
}

@test "leaves plain branch name unchanged" {
  bats_run_function git-branch-slug "main"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "preserves hyphens and underscores" {
  bats_run_function git-branch-slug "fix/my-bug_test"
  [ "$status" -eq 0 ]
  [ "$output" = "fix_my-bug_test" ]
}
