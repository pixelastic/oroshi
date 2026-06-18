bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock colors-load-definitions to provide controlled color keys
  colors-load-definitions() {
    declare -gA COLORS
    COLORS[git-branch-main]="color-main"
    COLORS[git-branch-head]="color-head"
    COLORS[git-branch]="color-default"
  }
  git-branch-current() { echo "main"; }
  bats_mock colors-load-definitions git-branch-current
}

@test "returns branch-specific color for known branch" {
  bats_run_zsh "git-branch-color main"
  [ "$status" -eq 0 ]
  [ "$output" = "color-main" ]
}

@test "lowercases branch name before lookup" {
  bats_run_zsh "git-branch-color HEAD"
  [ "$status" -eq 0 ]
  [ "$output" = "color-head" ]
}

@test "returns default color for unknown branch" {
  bats_run_zsh "git-branch-color some-feature"
  [ "$status" -eq 0 ]
  [ "$output" = "color-default" ]
}

@test "uses current branch when no arg given" {
  bats_run_zsh "git-branch-color"
  [ "$status" -eq 0 ]
  [ "$output" = "color-main" ]
}
