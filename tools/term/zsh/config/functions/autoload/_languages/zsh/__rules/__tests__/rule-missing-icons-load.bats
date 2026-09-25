bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-icons-load.zsh" "zshLintRule_missingIconsLoad" "test.zsh" "$@"
}

@test "flags \$ICONS[ without icons-load-definitions" {
  run_this_rule 'echo "$ICONS[tab]"'
  expect_rule_violation missingIconsLoad 1
}

@test "flags \${(k)ICONS} without icons-load-definitions" {
  run_this_rule 'for k in "${(k)ICONS}"; do echo "$k"; done'
  expect_rule_violation missingIconsLoad 1
}

@test "flags shebang script with \$ICONS[ and no loader" {
  run_this_rule '#!/usr/bin/env zsh' 'set -e' 'echo "$ICONS[tab]"'
  expect_rule_violation missingIconsLoad 3
}

@test "clean — no ICONS usage" {
  run_this_rule '# nothing here'
  expect_clean
}

@test "clean — \$ICONS[ with icons-load-definitions" {
  run_this_rule 'icons-load-definitions' 'echo "$ICONS[tab]"'
  expect_clean
}

@test "clean — \${(k)ICONS} with icons-load-definitions" {
  run_this_rule 'icons-load-definitions' 'for k in "${(k)ICONS}"; do echo "$k"; done'
  expect_clean
}

@test "clean — ICONS[ inside a jq string literal" {
  run_this_rule '# jq template' "jq -r 'to_entries[] | \"ICONS[\\(.key)]=\\(.value)\"' input.json"
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# use $ICONS[tab] for display'
  expect_clean
}

@test "line number is the first trigger line" {
  run_this_rule '# comment' 'echo "$ICONS[tab]"'
  expect_rule_violation missingIconsLoad 2
}
