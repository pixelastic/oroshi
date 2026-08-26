bats_load_library 'helper'

@test "prose-build generates dist/cfp-writer.ini" {
  bats_run_zsh "prose-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$OROSHI_ROOT/tools/prose/vale/dist/cfp-writer.ini" ]]
}

@test "prose-lint --profile cfp-writer runs without error on clean text" {
  vale() { printf '{}\n'; }
  bats_mock vale

  bats_run_zsh "prose-lint --profile cfp-writer 'Remove the obstacle.'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}
