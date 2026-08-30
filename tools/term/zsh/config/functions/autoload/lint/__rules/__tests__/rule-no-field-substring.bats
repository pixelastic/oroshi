bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-field-substring.zsh" "zshLintRule_noFieldSubstring" "test.zsh" "$@"
}

@test "flags %%▮* pattern" {
  run_this_rule 'local firstField="${line%%▮*}"'
  expect_rule_violation noFieldSubstring 1
}

@test "flags ##*▮ pattern" {
  run_this_rule 'local lastField="${line##*▮}"'
  expect_rule_violation noFieldSubstring 1
}

@test "flags %%▮ without trailing *" {
  run_this_rule 'local field="${var%%▮}"'
  expect_rule_violation noFieldSubstring 1
}

@test "flags ##▮ without leading *" {
  run_this_rule 'local field="${var##▮}"'
  expect_rule_violation noFieldSubstring 1
}

@test "clean — array splitting pattern" {
  run_this_rule 'local -a split=(${(@s/▮/)line})'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# local firstField="${line%%▮*}"'
  expect_clean
}

@test "clean — %% without ▮" {
  run_this_rule 'local base="${file%%.*}"'
  expect_clean
}

@test "clean — ## without ▮" {
  run_this_rule 'local ext="${file##*.}"'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '' 'local field="${var%%▮*}"'
  expect_rule_violation noFieldSubstring 3
}
