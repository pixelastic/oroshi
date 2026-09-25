bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-colors-load.zsh" "zshLintRule_missingColorsLoad" "test.zsh" "$@"
}

@test "flags \$COLORS[ without colors-load-definitions" {
  run_this_rule 'echo "$COLORS[red-1]"'
  expect_rule_violation missingColorsLoad 1
}

@test "flags \${(k)COLORS} without colors-load-definitions" {
  run_this_rule 'for k in "${(k)COLORS}"; do echo "$k"; done'
  expect_rule_violation missingColorsLoad 1
}

@test "flags shebang script with \$COLORS[ and no loader" {
  run_this_rule '#!/usr/bin/env zsh' 'set -e' 'echo "$COLORS[red-1]"'
  expect_rule_violation missingColorsLoad 3
}

@test "clean — no COLORS usage" {
  run_this_rule '# nothing here'
  expect_clean
}

@test "clean — \$COLORS[ with colors-load-definitions" {
  run_this_rule 'colors-load-definitions' 'echo "$COLORS[red-1]"'
  expect_clean
}

@test "clean — \${(k)COLORS} with colors-load-definitions" {
  run_this_rule 'colors-load-definitions' 'for k in "${(k)COLORS}"; do echo "$k"; done'
  expect_clean
}

@test "clean — COLORS[ without dollar sign (jq string)" {
  run_this_rule '# jq template' '"COLORS[\(.key)]=\(.value)"'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# use $COLORS[red-1] for display'
  expect_clean
}

@test "line number is the first trigger line" {
  run_this_rule '# comment' 'echo "$COLORS[red-1]"'
  expect_rule_violation missingColorsLoad 2
}
