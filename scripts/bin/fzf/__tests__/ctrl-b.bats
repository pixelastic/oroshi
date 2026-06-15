bats_load_library 'helper'

setup() {
  CURRENT="$BATS_TEST_DIRNAME/../ctrl-b"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: exits with status 0" {
  run "$CURRENT" --source
  [ "$status" -eq 0 ]
}

@test "fzf-source: outputs at least one command name" {
  run "$CURRENT" --source
  [ "${#lines[@]}" -gt 0 ]
}

@test "fzf-source: each line contains exactly one command name" {
  run "$CURRENT" --source
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != *" "* ]]
  done
}

# fzf-postprocess

@test "fzf-postprocess: outputs command name from stdin" {
  local result
  result="$(echo 'ls' | "$CURRENT" --postprocess)"
  [ "$result" = "ls" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  local result
  result="$(printf '' | "$CURRENT" --postprocess)"
  [ "$result" = "" ]
}
