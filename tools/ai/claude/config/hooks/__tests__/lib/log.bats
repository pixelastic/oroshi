bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export CLAUDE_HOOKS_LOG_DIR="${BATS_TMP_DIR}/hooks-log"
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/log.zsh'"
}

# logInput

@test "logInput writes last-bash-input.json for the name bash" {
  bats_run_zsh "${sourcePrefix}; logInput bash '{\"tool_name\":\"Bash\"}'"
  [[ "$status" -eq 0 ]]
  [[ -f "${CLAUDE_HOOKS_LOG_DIR}/last-bash-input.json" ]]
}

@test "logInput writes last-monitor-input.json and leaves the Bash file untouched" {
  mkdir -p "$CLAUDE_HOOKS_LOG_DIR"
  echo "bash-sentinel" >"${CLAUDE_HOOKS_LOG_DIR}/last-bash-input.json"

  bats_run_zsh "${sourcePrefix}; logInput monitor '{\"tool_name\":\"Monitor\"}'"
  [[ "$status" -eq 0 ]]
  [[ -f "${CLAUDE_HOOKS_LOG_DIR}/last-monitor-input.json" ]]
  [[ "$(cat "${CLAUDE_HOOKS_LOG_DIR}/last-bash-input.json")" = "bash-sentinel" ]]
}

@test "logInput creates the log directory when missing" {
  [[ ! -d "$CLAUDE_HOOKS_LOG_DIR" ]]
  bats_run_zsh "${sourcePrefix}; logInput bash '{\"a\":1}'"
  [[ "$status" -eq 0 ]]
  [[ -d "$CLAUDE_HOOKS_LOG_DIR" ]]
}

@test "logInput writes pretty-printed JSON equal to the input" {
  bats_run_zsh "${sourcePrefix}; logInput bash '{\"tool_input\":{\"command\":\"echo hello\"},\"cwd\":\"/tmp\"}'"
  [[ "$status" -eq 0 ]]
  local file="${CLAUDE_HOOKS_LOG_DIR}/last-bash-input.json"
  [[ "$(cat "$file")" = "$(jq '.' <<<'{"tool_input":{"command":"echo hello"},"cwd":"/tmp"}')" ]]
  [[ "$(wc -l <"$file")" -gt 1 ]]
}
