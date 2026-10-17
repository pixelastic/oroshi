bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"
  # Sandbox session dir so approval state stays isolated per test
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

# --- Integration tests (real Solkan) ---
# Slow (Solkan starts a node process): one simple case per verdict
# Rewrite rules and allow-lists are tested in lib/solkan.bats

@test "integration: allow rewrites the command and keeps the other tool input keys" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm -f a","description":"Remove a","timeout":5000,"run_in_background":true}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rm-guarded -f a'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Remove a'
  expect_json '.hookSpecificOutput.updatedInput.timeout' '5000'
  expect_json '.hookSpecificOutput.updatedInput.run_in_background' 'true'
}

@test "integration: reject asks with the reason and keeps the other tool input keys" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com","description":"Fetch","timeout":5000}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget evil.com'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Fetch'
  expect_json '.hookSpecificOutput.updatedInput.timeout' '5000'
}

# --- Mocked tests ---

@test "allow: auto-approves the command as is, sets CLAUDE_CWD before solkan and records no approval request" {
  solkanEvaluate() {
    print -r -- "$CLAUDE_CWD" > "$BATS_TMP_DIR/solkan-cwd.txt"
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"cwd":"/some/worktree","session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
  [[ "$(cat "$BATS_TMP_DIR/solkan-cwd.txt")" == "/some/worktree" ]]
  [[ ! -e "$BATS_TMP_DIR/test/state.json" ]]
}

@test "allow: uses the command rewritten by solkan" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND='rm-guarded foo.txt'
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm foo.txt"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rm-guarded foo.txt'
}

@test "preserves \xa0 as literal chars through full hook pipeline" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo \\xa0"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo \xa0'
}

@test "no background jobs in script" {
  run grep -E '[^&]&[[:space:]]*$' "$SCRIPT"
  [[ "$status" -ne 0 ]]
}

@test "reject: asks with the reason listing every rejected command, keeps the command and sends no systemMessage" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget evil.com && curl bad.com'
  expect_json_null '.hookSpecificOutput.systemMessage'
}

@test "repeat multi-reject in session: ask listing all rejected every time" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  local input='{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
}

@test "reject: opens an approval request for every rejected command and shows the moon of each approval count" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("/usr/bin/grep" "wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  local sourcePrefix="CLAUDE_SESSION_ID=test; CLAUDE_SESSION_DIR=\"\$CLAUDE_SESSIONS_DIR/test\"; source '$BATS_TEST_DIRNAME/../lib/approval-memory.zsh'"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep; approvalCountIncrement --command /usr/bin/grep; approvalCountIncrement --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"/usr/bin/grep x | wget evil.com | curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ /usr/bin/grep 🌕, wget 🌓, curl ❌'

  local stateFile="$BATS_TMP_DIR/test/state.json"
  [[ "$(jq --compact-output '.preToolUse.Bash.approvalRequest | map(select(.toolUseId == "toolu_01").commands[0])' "$stateFile")" = '["/usr/bin/grep","wget","curl"]' ]]
}

@test "prefixes command with CLAUDE_IS_SUBAGENT export when agent_id present" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"},"agent_id":"sub-123"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'export CLAUDE_IS_SUBAGENT=1; echo hello'
}

@test "prefixes command with CLAUDE_IS_SUBAGENT export on rejected path" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"},"agent_id":"sub-123"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'export CLAUDE_IS_SUBAGENT=1; wget evil.com'
}
