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

@test "--alias resolves alias to underlying function" {
  bats_run_zsh "CLAUDECODE=0 bin-zsh --alias ls --help"
  [[ "$status" -eq 0 ]]
  # ls is aliased to better-ls (wraps exa), not system ls
  [[ "$output" == *"exa"* ]]
}

@test "--alias still runs autoloaded functions" {
  bats_run_zsh "CLAUDECODE=0 bin-zsh --alias echo hello"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hello" ]]
}

@test "without --alias does not resolve aliases" {
  bats_run_zsh "bin-zsh ls --help"
  [[ "$status" -eq 0 ]]
  # Without --alias, ls is the system ls, not better-ls
  [[ "$output" != *"better-ls"* ]]
}
