bats_load_library 'helper'

@test "converts megabytes" {
  bats_run_zsh "filesize2bytes 25M"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "26214400" ]]
}

@test "converts gigabytes" {
  bats_run_zsh "filesize2bytes 1G"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1073741824" ]]
}

@test "converts kilobytes" {
  bats_run_zsh "filesize2bytes 500K"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "512000" ]]
}

@test "rejects invalid format" {
  bats_run_zsh "filesize2bytes invalid"
  [[ "$status" -ne 0 ]]
}

@test "rejects missing argument" {
  bats_run_zsh "filesize2bytes"
  [[ "$status" -ne 0 ]]
}
