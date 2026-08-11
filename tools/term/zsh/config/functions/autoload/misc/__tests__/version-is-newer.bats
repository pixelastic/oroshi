bats_load_library 'helper'

@test "returns 0 when first version is newer" {
  bats_run_zsh "version-is-newer 2.0.0 1.0.0"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 when first version is older" {
  bats_run_zsh "version-is-newer 1.0.0 2.0.0"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 when versions are equal" {
  bats_run_zsh "version-is-newer 1.0.0 1.0.0"
  [[ "$status" -eq 1 ]]
}

@test "compares minor versions" {
  bats_run_zsh "version-is-newer 1.2.0 1.1.0"
  [[ "$status" -eq 0 ]]
}

@test "compares patch versions" {
  bats_run_zsh "version-is-newer 1.0.2 1.0.1"
  [[ "$status" -eq 0 ]]
}

@test "major takes precedence over minor" {
  bats_run_zsh "version-is-newer 2.0.0 1.9.9"
  [[ "$status" -eq 0 ]]
}

@test "returns 1 with no arguments" {
  bats_run_zsh "version-is-newer"
  [[ "$status" -eq 1 ]]
}

@test "returns 1 with only one argument" {
  bats_run_zsh "version-is-newer 1.0.0"
  [[ "$status" -eq 1 ]]
}
