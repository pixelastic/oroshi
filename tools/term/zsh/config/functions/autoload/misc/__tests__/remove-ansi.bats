bats_load_library 'helper'

@test "strips simple color code" {
  bats_run_zsh "remove-ansi $'\033[31mhello\033[0m'"
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}

@test "strips 256-color code" {
  bats_run_zsh "remove-ansi $'\033[38;5;245mhello\033[0m'"
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}

@test "passes plain text through unchanged" {
  bats_run_zsh "remove-ansi 'hello world'"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}

@test "accepts piped input" {
  bats_run_zsh "printf '\033[31mhello\033[0m' | remove-ansi"
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}

@test "--reply writes to REPLY without echo" {
  bats_run_zsh "remove-ansi --reply $'\033[31mhello\033[0m'; echo \$REPLY"
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}
