bats_load_library 'helper'

@test "returns path to a known Go tool" {
  bats_run_zsh "go-tool-path golangci-lint"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"golangci-lint"* ]]
}

@test "returned path is an executable file" {
  bats_run_zsh "go-tool-path golangci-lint"
  [[ -x "$output" ]]
}

@test "exits 1 with no arguments" {
  bats_run_zsh "go-tool-path"
  [[ "$status" -eq 1 ]]
}

@test "exits non-zero for unknown tool" {
  bats_run_zsh "go-tool-path nonexistent-tool-xyz"
  [[ "$status" -ne 0 ]]
}
