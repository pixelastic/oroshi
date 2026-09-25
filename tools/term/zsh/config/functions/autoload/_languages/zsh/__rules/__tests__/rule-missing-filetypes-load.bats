bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-filetypes-load.zsh" "zshLintRule_missingFiletypesLoad" "test.zsh" "$@"
}

@test "flags \$FILETYPES[ without filetypes-load-definitions" {
  run_this_rule 'echo "$FILETYPES[md:color]"'
  expect_rule_violation missingFiletypesLoad 1
}

@test "flags \${(k)FILETYPES} without filetypes-load-definitions" {
  run_this_rule 'for k in "${(k)FILETYPES}"; do echo "$k"; done'
  expect_rule_violation missingFiletypesLoad 1
}

@test "clean — no FILETYPES usage" {
  run_this_rule '# nothing here'
  expect_clean
}

@test "clean — \$FILETYPES[ with filetypes-load-definitions" {
  run_this_rule 'filetypes-load-definitions' 'echo "$FILETYPES[md:color]"'
  expect_clean
}

@test "clean — \${(k)FILETYPES} with filetypes-load-definitions" {
  run_this_rule 'filetypes-load-definitions' 'for k in "${(k)FILETYPES}"; do echo "$k"; done'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# use $FILETYPES[md:color] for display'
  expect_clean
}

@test "line number is the first trigger line" {
  run_this_rule '# comment' 'echo "$FILETYPES[md:color]"'
  expect_rule_violation missingFiletypesLoad 2
}
