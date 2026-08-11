bats_load_library 'helper'

@test "sorts lines by ascending length" {
  input=$'long line here\nhi\nmedium'
  bats_run_zsh "sort-by-length" <<< "$input"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" = "hi" ]]
  [[ "${lines[1]}" = "medium" ]]
  [[ "${lines[2]}" = "long line here" ]]
}

@test "handles single line" {
  bats_run_zsh "sort-by-length" <<< "only"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "only" ]]
}

@test "handles empty input" {
  bats_run_zsh "sort-by-length" <<< ""
  [[ "$status" -eq 0 ]]
}
