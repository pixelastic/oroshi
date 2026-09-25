bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-projects-load.zsh" "zshLintRule_missingProjectsLoad" "test.zsh" "$@"
}

@test "flags \$PROJECTS[ without projects-load-definitions" {
  run_this_rule 'echo "$PROJECTS[oroshi:icon]"'
  expect_rule_violation missingProjectsLoad 1
}

@test "flags \${(k)PROJECTS} without projects-load-definitions" {
  run_this_rule 'for k in "${(k)PROJECTS}"; do echo "$k"; done'
  expect_rule_violation missingProjectsLoad 1
}

@test "flags shebang script with \$PROJECTS[ and no loader" {
  run_this_rule '#!/usr/bin/env zsh' 'set -e' 'echo "$PROJECTS[oroshi:icon]"'
  expect_rule_violation missingProjectsLoad 3
}

@test "clean — no PROJECTS usage" {
  run_this_rule '# nothing here'
  expect_clean
}

@test "clean — \$PROJECTS[ with projects-load-definitions" {
  run_this_rule 'projects-load-definitions' 'echo "$PROJECTS[oroshi:icon]"'
  expect_clean
}

@test "clean — \${(k)PROJECTS} with projects-load-definitions" {
  run_this_rule 'projects-load-definitions' 'for k in "${(k)PROJECTS}"; do echo "$k"; done'
  expect_clean
}

@test "clean — PROJECTS[ without dollar sign (jq string)" {
  run_this_rule '# jq template' '"PROJECTS[\(.key)]=\(.value)"'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# use $PROJECTS[oroshi:icon] for display'
  expect_clean
}

@test "line number is the first trigger line" {
  run_this_rule '# comment' 'echo "$PROJECTS[oroshi:icon]"'
  expect_rule_violation missingProjectsLoad 2
}
