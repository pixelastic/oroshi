bats_load_library 'helper'

@test "prose-lint --profile cfp-writer runs without error on clean text" {
  vale() { printf '{}\n'; }
  bats_mock vale

  bats_run_zsh "prose-lint --profile cfp-writer 'Remove the obstacle.'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}
