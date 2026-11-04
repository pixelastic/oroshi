bats_load_library 'helper'

@test "prints blocking when at least one blocking finding exists" {
  bats_run_zsh "documentation-tighten-severity --blocking 1 --important 0 --nitpick 25"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "🔴 blocking" ]]
}

@test "prints important when no blocking finding exists" {
  bats_run_zsh "documentation-tighten-severity --blocking 0 --important 2 --nitpick 5"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "🟠 important" ]]
}

@test "prints nitpick when only nitpicks exist" {
  bats_run_zsh "documentation-tighten-severity --blocking 0 --important 0 --nitpick 25"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "🟡 nitpick" ]]
}

@test "prints none when every count is zero" {
  bats_run_zsh "documentation-tighten-severity --blocking 0 --important 0 --nitpick 0"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "🟢 none" ]]
}

@test "accepts the flags in any order" {
  bats_run_zsh "documentation-tighten-severity --nitpick 3 --blocking 0 --important 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "🟠 important" ]]
}

@test "fails when a flag is missing" {
  bats_run_zsh "documentation-tighten-severity --blocking 0 --important 0"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "fails when a count is not a non-negative integer" {
  bats_run_zsh "documentation-tighten-severity --blocking x --important 0 --nitpick 0"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "fails when a count is negative" {
  bats_run_zsh "documentation-tighten-severity --blocking 0 --important -1 --nitpick 0"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}
