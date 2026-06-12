setup_file() {
  # ~/.zshenv may use an old OROSHI_ROOT when OROSHI_ROOT points to a worktree
  # that has moved the config tree. Override ZDOTDIR so subprocess zsh processes
  # source the correct zshenv instead.
  local oroshi="${OROSHI_ROOT:-$HOME/.oroshi}"
  local zshenv="$oroshi/tools/term/zsh/config/zshenv.zsh"
  [[ -f "$zshenv" ]] || return 0
  local tmpZdotdir
  tmpZdotdir="$(mktemp -d)"
  printf 'export OROSHI_ROOT="%s"\nsource "%s"\n' "$oroshi" "$zshenv" >"$tmpZdotdir/.zshenv"
  export ZDOTDIR="$tmpZdotdir"
}

teardown_file() {
  [[ -d "${ZDOTDIR:-}" ]] && rm -rf "$ZDOTDIR"
}

@test "returns path for a colocalized script" {
  run bats-test-path "$OROSHI_ROOT/scripts/bin/text/text-select-line"
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_ROOT/scripts/bin/text/__tests__/text-select-line.bats" ]
}

@test "returns path for an autoloaded zsh function" {
  run bats-test-path "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/slugify"
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/__tests__/slugify.bats" ]
}

@test "returns the bats file path when given a .bats file" {
  run bats-test-path "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/__tests__/slugify.bats"
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/misc/__tests__/slugify.bats" ]
}

@test "returns 1 if no test file exists" {
  run bats-test-path "$OROSHI_ROOT/scripts/bin/term/bats/bats-echo"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "returns 1 with no arguments" {
  run bats-test-path
  [ "$status" -eq 1 ]
}

@test "strips extension and adds .bats for a .zsh file" {
  run bats-test-path "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/__rules/rule-no-dash-n.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "$OROSHI_ROOT/scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-no-dash-n.bats" ]
}
