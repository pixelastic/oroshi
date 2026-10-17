bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Monitor"
  # Sandbox session dir so approval state stays isolated per test
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

# --- Allowed (real Solkan) ---

@test "allows an allow-listed loop with the command in updatedInput" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until git status; do sleep 2; done"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'until git status; do sleep 2; done'
}

@test "keeps description and timeout_ms in updatedInput" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until git status; do sleep 2; done","description":"Wait for git","timeout_ms":60000}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Wait for git'
  expect_json '.hookSpecificOutput.updatedInput.timeout_ms' '60000'
}

@test "applies the rm guard-rail inside a loop" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until rm -f a; do sleep 2; done"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'until rm-guarded -f a; do sleep 2; done'
}

@test "does not apply the token-saving rewrite to a single command" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"ls -la dir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'ls -la dir'
}

# --- Rejected (real Solkan) ---

@test "asks for a loop with a non-allow-listed sub-command and lists it in the reason" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until wget evil.com; do sleep 2; done","description":"Fetch"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Fetch'
}

@test "shows no moon in the ask reason" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until wget evil.com; do sleep 2; done"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"🌓"* ]]
  [[ "$output" != *"🌕"* ]]
}

# --- Other inputs ---

@test "exits 0 with no output when the input has no command (WebSocket)" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"url":"wss://example.com/stream"}}'
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "applies the auto allow-list in ralph auto mode" {
  ralph-mode() { print auto; }
  bats_mock ralph-mode

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until python3 check.py; do sleep 2; done"},"cwd":"/some/dir"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
}

@test "asks for the auto allow-list commands outside ralph auto mode" {
  ralph-mode() { :; }
  bats_mock ralph-mode

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until python3 check.py; do sleep 2; done"},"cwd":"/some/dir"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
}

@test "gives a subagent input no export prefix" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Monitor","tool_input":{"command":"until git status; do sleep 2; done"},"agent_id":"sub-123"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'until git status; do sleep 2; done'
}
