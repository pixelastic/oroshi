bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-and-block.zsh" "zshLintRule_noAndBlock" "test.zsh" "$@"
}

@test "flags ]] && {" {
  run_this_rule '[[ "$slug" == "" ]] && {'
  expect_rule_violation noAndBlock 1
}

@test "flags ]]&&{ (no spaces)" {
  run_this_rule '[[ "$slug" == "" ]]&&{'
  expect_rule_violation noAndBlock 1
}

@test "flags ]] &&{ (no space after &&)" {
  run_this_rule '[[ "$slug" == "" ]] &&{'
  expect_rule_violation noAndBlock 1
}

@test "flags ]] && { # comment" {
  run_this_rule '[[ "$slug" == "" ]] && { # block start'
  expect_rule_violation noAndBlock 1
}

@test "flags ]] && { cmd; cmd } one-liner" {
  run_this_rule '[[ "$slug" == "" ]] && { print "err"; exit 1 }'
  expect_rule_violation noAndBlock 1
}

@test "clean — ]] && return 1" {
  run_this_rule '[[ "$slug" == "" ]] && return 1'
  expect_clean
}

@test "clean — ]] && some-command" {
  run_this_rule '[[ "$slug" == "" ]] && print "error"'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ "$slug" == "" ]] && {'
  expect_clean
}

@test "clean — && { without ]]" {
  run_this_rule 'some-command && {'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ "$slug" == "" ]] && {'
  expect_rule_violation noAndBlock 2
}
