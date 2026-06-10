#!/usr/bin/env bats

bats_load_library 'helper'
bats_load_library 'rules-helper'

# Fixture lives at the autoload subpath within the mocked OROSHI_ROOT
run_this_rule() {
  bats_tmp_dir
  bats_mock_oroshi_root "$BATS_TMP_DIR"
  mkdir -p "$BATS_TMP_DIR/tools/term/zsh/config/functions/autoload"
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-err-return.zsh" "zshLintRule_missingErrReturn" "tools/term/zsh/config/functions/autoload/test" "$@"
}

@test "clean — not in autoload dir (e.g. compdef)" {
  bats_tmp_dir
  bats_mock_oroshi_root "$BATS_TMP_DIR"
  local -a input=( '#compdef' 'function _jumps() { echo hello; }' )
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-err-return.zsh" "zshLintRule_missingErrReturn" "test" "${input[@]}"
  expect_clean
}

@test "flags autoloaded function missing setopt err_return" {
  local -a input=( '# My function' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingErrReturn 1
}

@test "clean — setopt local_options err_return present" {
  local -a input=( '# My function' 'setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — has shebang (script, not an autoloaded function)" {
  local -a input=( '#!/usr/bin/env zsh' '# My script' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_clean
}

@test "clean — .zsh extension (sourced utility, not an autoloaded function)" {
  run_rule "${BATS_TEST_DIRNAME}/../rule-missing-err-return.zsh" "zshLintRule_missingErrReturn" "test.zsh" \
    '# sourced utility' \
    'echo hello'
  expect_clean
}

@test "flags — setopt err_return in a comment does not count" {
  local -a input=( '# setopt local_options err_return' 'echo hello' )
  run_this_rule "${input[@]}"
  expect_rule_violation missingErrReturn 1
}
