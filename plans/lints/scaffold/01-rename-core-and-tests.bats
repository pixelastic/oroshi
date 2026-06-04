#!/usr/bin/env bats

bats_load_library 'helper'

@test "no directory named zshlint under scripts/bin/zsh" {
  [[ ! -d "$OROSHI_ROOT/scripts/bin/zsh/zshlint" ]]
}

@test "zsh-lint script exists" {
  [[ -f "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/zsh-lint" ]]
}

@test "zsh-lint-shellcheck script exists" {
  [[ -f "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/zsh-lint-shellcheck" ]]
}

@test "zsh-lint-custom script exists" {
  [[ -f "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/zsh-lint-custom" ]]
}

@test "no zshlintRule_ function names in any rule file" {
  run grep -r "zshlintRule_" "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/__rules/"
  [[ "$status" -eq 1 ]]
}

@test "no zshlint-disable comments in zsh-lint source files" {
  run grep -r --include="*.zsh" "# zshlint-disable" "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/"
  [[ "$status" -eq 1 ]]
}
