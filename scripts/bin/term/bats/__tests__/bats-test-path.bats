@test "returns path for a colocalized script" {
  run bats-test-path "$HOME/.oroshi/scripts/bin/text/text-select-line"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.oroshi/scripts/bin/text/__tests__/text-select-line.bats" ]
}

@test "returns path for an autoloaded zsh function" {
  run bats-test-path "$HOME/.oroshi/config/term/zsh/functions/autoload/misc/slugify"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.oroshi/config/term/zsh/functions/autoload/misc/__tests__/slugify.bats" ]
}

@test "returns the bats file path when given a .bats file" {
  run bats-test-path "$HOME/.oroshi/config/term/zsh/functions/autoload/misc/__tests__/slugify.bats"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.oroshi/config/term/zsh/functions/autoload/misc/__tests__/slugify.bats" ]
}

@test "returns 1 if no test file exists" {
  run bats-test-path "$HOME/.oroshi/scripts/bin/term/bats/bats-echo"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "returns 1 with no arguments" {
  run bats-test-path
  [ "$status" -eq 1 ]
}

@test "strips extension and adds .bats for a .zsh file" {
  run bats-test-path "$HOME/.oroshi/scripts/bin/zsh/zshlint/__rules/rule-no-dash-n.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.oroshi/scripts/bin/zsh/zshlint/__rules/__tests__/rule-no-dash-n.bats" ]
}
