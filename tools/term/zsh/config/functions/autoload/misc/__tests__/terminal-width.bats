bats_load_library 'helper'

@test "returns a positive integer" {
  bats_run_zsh "terminal-width"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
  [[ "$output" -gt 0 ]]
}

@test "supports --reply flag" {
  bats_run_zsh "terminal-width --reply && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
  [[ "$output" -gt 0 ]]
}

@test "works inside a command substitution" {
  bats_run_zsh 'echo "$(terminal-width)"'
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+$ ]]
  [[ "$output" -gt 0 ]]
}

@test "falls back to 80 when no terminal is available" {
  bats_run_zsh "terminal-width </dev/null 2>/dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$output" -gt 0 ]]
}
