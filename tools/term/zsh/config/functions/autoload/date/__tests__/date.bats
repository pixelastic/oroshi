bats_load_library 'helper'

@test "date-month-length gives 29 days to February of a leap year" {
  bats_run_zsh "date-month-length 2024-02"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "29" ]]
}

@test "date-month-length gives 28 days to February of a century year" {
  bats_run_zsh "date-month-length 1900-02"
  [[ "$output" = "28" ]]
}

@test "date-is-valid accepts a year, a month and a day" {
  bats_run_zsh "date-is-valid 2024 && date-is-valid 2024-02 && date-is-valid 2024-02-29"
  [[ "$status" -eq 0 ]]
}

@test "date-is-valid rejects the 30th of February" {
  bats_run_zsh "date-is-valid 2024-02-30"
  [[ "$status" -eq 1 ]]
}

@test "date-is-valid rejects a malformed date" {
  bats_run_zsh "date-is-valid 24-02"
  [[ "$status" -eq 1 ]]
}

@test "date-expand keeps a full date" {
  bats_run_zsh "date-expand --last 2024-03-05"
  [[ "$output" = "2024-03-05" ]]
}

@test "date-expand gives the first day of a month and of a year" {
  bats_run_zsh "date-expand 2024-03; date-expand 2024"
  [[ "$output" = $'2024-03-01\n2024-01-01' ]]
}

@test "date-expand gives the last day of a month and of a year" {
  bats_run_zsh "date-expand --last 2024-02; date-expand --last 2024"
  [[ "$output" = $'2024-02-29\n2024-12-31' ]]
}
