bats_load_library 'helper'

@test "strips simple color code" {
  bats_run_zsh "text-ansi-remove $'\033[31mhello\033[0m'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "strips 256-color code" {
  bats_run_zsh "text-ansi-remove $'\033[38;5;245mhello\033[0m'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "passes plain text through unchanged" {
  bats_run_zsh "text-ansi-remove 'hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello world" ]]
}

@test "accepts piped input" {
  bats_run_zsh "printf '\033[31mhello\033[0m' | text-ansi-remove"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "--reply writes to REPLY without echo" {
  bats_run_zsh "text-ansi-remove --reply $'\033[31mhello\033[0m'; echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}
