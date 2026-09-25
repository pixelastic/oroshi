bats_load_library 'helper'
bats_load_library 'rules-helper'

# Fixture lives at the autoload subpath within the mocked OROSHI_ROOT
run_this_rule() {
  bats_tmp_dir
  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/functions/autoload"
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-doc-comment.zsh" "zshLintRule_missingDocComment" "tools/term/zsh/config/functions/autoload/test" "$@"
}

run_script_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-doc-comment.zsh" "zshLintRule_missingDocComment" "test.zsh" "$@"
}

@test "flags autoloaded function with no comment on line 1" {
  local -a input=( 'setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingDocComment 1
}

@test "flags script with no comment on line 2" {
  local -a input=( '#!/usr/bin/env zsh' 'set -e' 'echo hello' )
  run_script_rule "${input[@]}"
  expect_rule_violation missingDocComment 2
}

@test "clean — autoloaded function has comment on line 1" {
  local -a input=( '# My function' 'setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — script has comment on line 2" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'set -e' 'echo hello' )
  run_script_rule "${input[@]}"
  expect_clean
}

@test "clean — skips __lib/ files" {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/some/__lib"
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-doc-comment.zsh" "zshLintRule_missingDocComment" "some/__lib/helper.zsh" \
    'echo no comment here'
  expect_clean
}

@test "clean — skips __rules/ files" {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/some/__rules"
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-doc-comment.zsh" "zshLintRule_missingDocComment" "some/__rules/rule.zsh" \
    'echo no comment here'
  expect_clean
}

@test "clean — skips __tests__/ files" {
  bats_tmp_dir
  mkdir -p "$BATS_TMP_DIR/some/__tests__"
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-doc-comment.zsh" "zshLintRule_missingDocComment" "some/__tests__/fixture.zsh" \
    'echo no comment here'
  expect_clean
}
