#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

setup() {
  RULE_PATH="${BATS_TEST_DIRNAME}/../rule-prefer-zsh-autoload.zsh"
}

run_this_rule() {
  run_rule "$RULE_PATH" "batsLintRule_preferZshAutoload" "test.bats" "$@"
}

@test "detects CURRENT using OROSHI_ROOT autoload path" {
  run_this_rule '  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/branch/git-branch-current"'
  expect_rule_violation preferZshAutoload 1
}

@test "no violation when using OROSHI_ZSH_AUTOLOAD" {
  run_this_rule '  CURRENT="$OROSHI_ZSH_AUTOLOAD/git/branch/git-branch-current"'
  expect_clean
}

@test "no violation for unrelated OROSHI_ROOT path" {
  run_this_rule '  SCRIPT="$OROSHI_ROOT/scripts/bin/term/bats/bats-lint/bats-lint"'
  expect_clean
}

@test "no violation for BATS_TEST_DIRNAME path" {
  run_this_rule '  CURRENT="${BATS_TEST_DIRNAME}/../my-script.zsh"'
  expect_clean
}

@test "no violation when path is in a comment" {
  run_this_rule '# CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fn"'
  expect_clean
}

@test "correct line number" {
  run_this_rule \
    'setup() {' \
    '  bats_tmp_dir' \
    '  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/branch/git-branch-current"' \
    '}'
  expect_rule_violation preferZshAutoload 3
}
