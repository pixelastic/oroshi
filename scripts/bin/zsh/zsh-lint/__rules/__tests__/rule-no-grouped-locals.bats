bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-grouped-locals.zsh" "zshLintRule_noGroupedLocals" "test.zsh" "$@"
}

@test "flags local with multiple bare names" {
  local -a input=( 'local a b c' )
  run_this_rule "${input[@]}"
  expect_rule_violation noGroupedLocals 1
}

@test "flags local with multiple assignments" {
  local -a input=( 'local raw="" line="" path=""' )
  run_this_rule "${input[@]}"
  expect_rule_violation noGroupedLocals 1
}

@test "flags local with flag and multiple variables" {
  local -a input=( 'local -a arr1 arr2' )
  run_this_rule "${input[@]}"
  expect_rule_violation noGroupedLocals 1
}

@test "flags local with flag and multiple assignments" {
  local -a input=( 'local -i count=0 limit=10' )
  run_this_rule "${input[@]}"
  expect_rule_violation noGroupedLocals 1
}

@test "clean — single variable with flag" {
  local -a input=( 'local -a arr' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — single assignment with flag" {
  local -a input=( 'local -r VAR=val' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — array literal with spaces" {
  local -a input=( 'local -a arr=(a b c)' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — quoted value with spaces" {
  local -a input=( 'local msg="hello world"' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# local a b c' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — empty array assignment" {
  local -a input=( 'local -a input=()' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — array literal without -a flag" {
  local -a input=( 'local claudeArgs=(--print --model sonnet --session-id "$sessionId")' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — single assignment with inline comment" {
  local -a input=( 'local cacheDuration=1440 # In minutes' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "line number is correct when preceded by blank line" {
  run_this_rule '' 'local a b'
  expect_rule_violation noGroupedLocals 2
}
