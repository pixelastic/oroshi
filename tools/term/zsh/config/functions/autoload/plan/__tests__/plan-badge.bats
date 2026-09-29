bats_load_library 'helper'

setup() {
  plan-progress() { echo "4▮5"; }
  bats_mock plan-progress
}

@test "separates the icon from the progress with an en space" {
  bats_run_zsh "plan-badge /some/plan"
  [[ "$status" -eq 0 ]]
  [[ "$(bats_strip_ansi "$output")" == *$' '"4/5" ]]
}
