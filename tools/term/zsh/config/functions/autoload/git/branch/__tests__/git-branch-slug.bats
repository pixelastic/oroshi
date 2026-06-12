bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TEST_DIRNAME/../git-branch-slug"
}

teardown() {
  bats_cleanup
}

@test "replaces single slash with underscore" {
  bats_run_zsh "$CURRENT" "feat/my-feature"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_my-feature" ]
}

@test "replaces multiple slashes with underscores" {
  bats_run_zsh "$CURRENT" "feat/scope/deep"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_scope_deep" ]
}

@test "leaves plain branch name unchanged" {
  bats_run_zsh "$CURRENT" "main"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "preserves hyphens and underscores" {
  bats_run_zsh "$CURRENT" "fix/my-bug_test"
  [ "$status" -eq 0 ]
  [ "$output" = "fix_my-bug_test" ]
}

@test "replaces dots with hyphens" {
  bats_run_zsh "$CURRENT" "progress.json"
  [ "$status" -eq 0 ]
  [ "$output" = "progress-json" ]
}

@test "replaces slashes and dots in combination" {
  bats_run_zsh "$CURRENT" "feat/fix.thing"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_fix-thing" ]
}

@test "defaults to current branch when no argument given" {
  git-branch-current() { echo "feat/my.feature"; }
  bats_mock git-branch-current

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "feat_my-feature" ]
}
