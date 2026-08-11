bats_load_library 'helper'

@test "decodes base64 string" {
  bats_run_zsh "base64-decode 'aGVsbG8gd29ybGQ='"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "hello world" ]]
}

@test "decodes empty base64" {
  bats_run_zsh "base64-decode ''"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
