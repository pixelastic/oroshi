bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock OROSHI_ROOT with a symlinked claude binary, like yarn does
  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR/oroshi"
  mkdir -p "$BATS_TMP_DIR/oroshi/node_modules/.bin" "$BATS_TMP_DIR/oroshi/node_modules/@anthropic-ai/claude-code/bin"
  touch "$BATS_TMP_DIR/oroshi/node_modules/@anthropic-ai/claude-code/bin/claude.exe"
  ln -s ../@anthropic-ai/claude-code/bin/claude.exe "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  node() { echo "$@"; }
  bats_mock node
}

@test "patches the resolved yarn claude binary" {
  bats_run_zsh "$BATS_TEST_DIRNAME/../generate-suggestion"

  local args
  read -r -a args <<<"$output"
  [[ "$status" -eq 0 ]]
  [[ "${args[0]}" == */tools/ai/claude/config/patch/suggestion/src/main.js ]]
  [[ "${args[1]}" == "--binary" ]]
  [[ "${args[2]}" == "$BATS_TMP_DIR/oroshi/node_modules/@anthropic-ai/claude-code/bin/claude.exe" ]]
}

@test "fails when claude is not installed" {
  rm "$BATS_TMP_DIR/oroshi/node_modules/.bin/claude"

  bats_run_zsh "$BATS_TEST_DIRNAME/../generate-suggestion"

  [[ "$status" -eq 1 ]]
  [[ "$output" == "✘ No Claude Code binary"* ]]
}
