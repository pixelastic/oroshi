bats_load_library 'helper'

@test "encodes string to base64" {
  bats_run_zsh "base64-encode 'hello world'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "aGVsbG8gd29ybGQ=" ]]
}

@test "encodes empty string" {
  bats_run_zsh "base64-encode ''"
  [[ "$status" -eq 0 ]]
}
