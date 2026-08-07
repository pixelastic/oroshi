bats_load_library 'helper'

@test "calls autoloaded function and returns its output" {
  bats_run_zsh "bin-zsh echo hello"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hello" ]]
}

@test "forwards multiple arguments" {
  bats_run_zsh "bin-zsh echo hello world"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hello world" ]]
}

@test "propagates non-zero exit code" {
  bats_run_zsh "bin-zsh false"
  [[ "$status" -ne 0 ]]
}

@test "forwards --flag arguments" {
  bats_run_zsh "bin-zsh echo --verbose --dry-run"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "--verbose --dry-run" ]]
}

@test "forwards piped stdin" {
  bats_run_zsh "echo 'piped content' | bin-zsh cat"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "piped content" ]]
}

@test "fails with usage message when called without arguments" {
  bats_run_zsh "bin-zsh"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}
