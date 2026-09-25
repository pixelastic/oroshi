bats_load_library 'helper'
bats_load_library 'rules-helper'

run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-chained-and.zsh" "zshLintRule_noChainedAnd" "test.zsh" "$@"
}

@test "flags ]] && cmd && cmd" {
  run_this_rule '[[ "$x" == "1" ]] && cmd1 && cmd2'
  expect_rule_violation noChainedAnd 1
}

@test "flags three-chain" {
  run_this_rule '[[ "$x" == "1" ]] && cmd1 && cmd2 && cmd3'
  expect_rule_violation noChainedAnd 1
}

@test "flags exact bug report case" {
  run_this_rule '[[ ! -f "$attentionFile" ]] && mkdir -p "${attentionFile:h}" && touch "$attentionFile"'
  expect_rule_violation noChainedAnd 1
}

@test "clean — single && after ]]" {
  run_this_rule '[[ "$slug" == "" ]] && return 1'
  expect_clean
}

@test "clean — comment line" {
  run_this_rule '# [[ "$x" ]] && cmd1 && cmd2'
  expect_clean
}

@test "line number is correct" {
  run_this_rule '' '[[ "$x" ]] && cmd1 && cmd2'
  expect_rule_violation noChainedAnd 2
}
