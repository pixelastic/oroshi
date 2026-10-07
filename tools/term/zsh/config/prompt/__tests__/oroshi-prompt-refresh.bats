bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '$BATS_TEST_DIRNAME/../hooks/prompt-populate.zsh'"

  # Fake prompt hooks: record the order in which they run
  oroshi-git-env-store() { echo "git-env" >>"$BATS_TMP_DIR/order"; }
  oroshi-prompt-synchronous-populate() { echo "sync-populate" >>"$BATS_TMP_DIR/order"; }
  oroshi-prompt-asynchronous-populate() { echo "async-populate" >>"$BATS_TMP_DIR/order"; }
  bats_mock oroshi-git-env-store oroshi-prompt-synchronous-populate oroshi-prompt-asynchronous-populate
}

@test "refreshes git env, then synchronous parts, then asynchronous parts" {
  bats_run_zsh "$sourcePrefix && oroshi-prompt-refresh"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/order")" = $'git-env\nsync-populate\nasync-populate' ]]
}

@test "precmd runs the refresh instead of the individual hooks" {
  bats_run_zsh "source '$BATS_TEST_DIRNAME/../hooks/index.zsh' 2>/dev/null; echo \${(j: :)precmd_functions}"
  [[ "$output" = *"oroshi-prompt-refresh"* ]]
  [[ "$output" != *"oroshi-prompt-synchronous-populate"* ]]
  [[ "$output" != *"oroshi-prompt-asynchronous-populate"* ]]
  [[ "$output" != *"oroshi-git-env-store"* ]]
}

@test "refreshes every part even when a step fails under err_return" {
  oroshi-prompt-synchronous-populate() {
    echo "sync-populate" >>"$BATS_TMP_DIR/order"
    return 1
  }
  bats_mock oroshi-prompt-synchronous-populate

  bats_run_zsh "setopt err_return; $sourcePrefix && oroshi-prompt-refresh"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/order")" = $'git-env\nsync-populate\nasync-populate' ]]
}
