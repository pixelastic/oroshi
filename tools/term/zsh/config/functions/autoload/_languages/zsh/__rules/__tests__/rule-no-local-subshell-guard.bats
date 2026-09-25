bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-local-subshell-guard.zsh" "zshLintRule_noLocalSubshellGuard" "test.zsh" "$@"
}

@test "flags local with || true inside subshell" {
  local -a input=( 'local x="$(cmd || true)"' )
  run_this_rule "${input[@]}"
  expect_rule_violation noLocalSubshellGuard 1
}

@test "flags local with combined pattern" {
  local -a input=( 'local x="$(cmd 2>/dev/null || true)"' )
  run_this_rule "${input[@]}"
  expect_rule_violation noLocalSubshellGuard 1
}

@test "reports correct line number" {
  local -a input=( 'local clean="foo"' 'local x="$(cmd || true)"' )
  run_this_rule "${input[@]}"
  expect_rule_violation noLocalSubshellGuard 2
}

@test "clean — no guard" {
  local -a input=( 'local x="$(cmd)"' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — bare assignment, guard is needed" {
  local -a input=( 'x="$(cmd || true)"' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — comment line" {
  local -a input=( '# local x="$(cmd || true)"' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — literal string, not inside subshell" {
  local -a input=( 'local x="yes || true"' )
  run_this_rule "${input[@]}"
  expect_clean
}
