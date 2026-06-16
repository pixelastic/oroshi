bats_load_library 'helper'

# --- Default (full hash) ---

@test "returns 32-char md5 hash" {
  bats_run_zsh "md5 'hello'"
  [ "$status" -eq 0 ]
  [ "${#output}" -eq 32 ]
}

@test "returns correct hash for known input" {
  bats_run_zsh "md5 'hello'"
  [ "$output" = "5d41402abc4b2a76b9719d911017c592" ]
}

# --- --short flag ---

@test "--short returns 8-char hash" {
  bats_run_zsh "md5 --short 'hello'"
  [ "$status" -eq 0 ]
  [ "${#output}" -eq 8 ]
}

@test "--short returns first 8 chars of full hash" {
  bats_run_zsh "md5 --short 'hello'"
  [ "$output" = "5d41402a" ]
}
