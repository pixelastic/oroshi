bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-manual-arg-parsing.zsh" "zshLintRule_noManualArgParsing" "test.zsh" "$@"
}

@test "flags case \"\$1\" pattern" {
  local -a input=(
    'case "$1" in'
    '  --foo) foo=1 ;;'
    'esac'
  )
  run_this_rule "${input[@]}"
  expect_rule_violation noManualArgParsing 1
}

@test "flags while getopts pattern" {
  local -a input=( 'while getopts "f:v" opt; do' )
  run_this_rule "${input[@]}"
  expect_rule_violation noManualArgParsing 1
}

@test "clean — zparseopts" {
  local -a input=(
    'zmodload zsh/zutil'
    'zparseopts -E -D f=flagFoo'
  )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "no false positive on comment line" {
  local -a input=( '# case "$1" is the old way' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "no false positive on case \"\$2\"" {
  local -a input=( 'case "$2" in' )
  run_this_rule "${input[@]}"
  expect_clean
}
