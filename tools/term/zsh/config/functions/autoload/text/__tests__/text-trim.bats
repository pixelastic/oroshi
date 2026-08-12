bats_load_library 'helper'

@test "trims leading and trailing whitespace" {
  bats_run_zsh "text-trim '  hello world  '"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello world" ]]
}

@test "trims tabs and newlines" {
  bats_run_zsh "text-trim $'\t hello \n'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "passes clean text unchanged" {
  bats_run_zsh "text-trim 'hello'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}

@test "accepts piped input" {
  bats_run_zsh "echo '  hello  ' | text-trim"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello" ]]
}
