bats_load_library 'helper'

@test "selects line by index from argument" {
  bats_run_zsh "text-line-get 'one\ntwo' 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "one" ]]
}

@test "selects second line from argument" {
  bats_run_zsh "text-line-get 'one\ntwo\nthree' 2"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "two" ]]
}

@test "accepts piped input" {
  bats_run_zsh "echo 'one\ntwo' | text-line-get 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "one" ]]
}
