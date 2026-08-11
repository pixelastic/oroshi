bats_load_library 'helper'

@test "returns short string unchanged" {
  bats_run_zsh "truncate-to-width --width 20 'hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello world" ]]
}

@test "truncates long string with ellipsis" {
  bats_run_zsh "truncate-to-width --width 10 'hello beautiful world'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello bea…" ]]
}

@test "returns string unchanged when exactly at width" {
  bats_run_zsh "truncate-to-width --width 5 'hello'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "truncates string one char over width" {
  bats_run_zsh "truncate-to-width --width 5 'helloo'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hell…" ]]
}

@test "skips ANSI sequences when counting visible width" {
  bats_run_zsh "truncate-to-width --width 10 $'\033[31mhello world\033[0m'"
  [[ "$status" -eq 0 ]]
  # Should keep the ANSI codes + 9 visible chars + ellipsis + reset
  [[ "$output" == *"hello wor…"* ]]
}

@test "adds ANSI reset after ellipsis when truncating colored text" {
  bats_run_zsh "truncate-to-width --width 6 $'\033[31mhello world\033[0m'"
  [[ "$status" -eq 0 ]]
  # Ends with ellipsis + ANSI reset
  [[ "$output" == *$'…\033[0m' ]]
}

@test "does not add ANSI reset when not truncating" {
  bats_run_zsh "truncate-to-width --width 20 'hello'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "supports --reply flag" {
  bats_run_zsh "truncate-to-width --reply --width 5 'helloo'; echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hell…" ]]
}

@test "defaults to terminal width when no --width given" {
  bats_run_zsh "truncate-to-width 'short'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "short" ]]
}
