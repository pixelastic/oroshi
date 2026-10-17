bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env OROSHI_FOLDER_CACHE "$BATS_TMP_DIR"
  LOG_DIR="${BATS_TMP_DIR}/claude/hooks"
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/log.zsh'"
}

# logInput

@test "logInput writes last-bash-input.json for the name bash" {
  bats_run_zsh "${sourcePrefix}; CLAUDE_HOOK_INPUT='{\"tool_name\":\"Bash\"}'; logInput bash"
  [[ "$status" -eq 0 ]]
  [[ -f "${LOG_DIR}/last-bash-input.json" ]]
}

@test "logInput writes last-monitor-input.json and leaves the Bash file untouched" {
  mkdir -p "$LOG_DIR"
  echo "bash-sentinel" >"${LOG_DIR}/last-bash-input.json"

  bats_run_zsh "${sourcePrefix}; CLAUDE_HOOK_INPUT='{\"tool_name\":\"Monitor\"}'; logInput monitor"
  [[ "$status" -eq 0 ]]
  [[ -f "${LOG_DIR}/last-monitor-input.json" ]]
  [[ "$(cat "${LOG_DIR}/last-bash-input.json")" = "bash-sentinel" ]]
}

@test "logInput creates the log directory when missing" {
  [[ ! -d "$LOG_DIR" ]]
  bats_run_zsh "${sourcePrefix}; CLAUDE_HOOK_INPUT='{\"a\":1}'; logInput bash"
  [[ "$status" -eq 0 ]]
  [[ -d "$LOG_DIR" ]]
}

@test "logInput writes pretty-printed JSON equal to the input" {
  bats_run_zsh "${sourcePrefix}; CLAUDE_HOOK_INPUT='{\"tool_input\":{\"command\":\"echo hello\"},\"cwd\":\"/tmp\"}'; logInput bash"
  [[ "$status" -eq 0 ]]
  local file="${LOG_DIR}/last-bash-input.json"
  [[ "$(cat "$file")" = "$(jq '.' <<<'{"tool_input":{"command":"echo hello"},"cwd":"/tmp"}')" ]]
  [[ "$(wc -l <"$file")" -gt 1 ]]
}
