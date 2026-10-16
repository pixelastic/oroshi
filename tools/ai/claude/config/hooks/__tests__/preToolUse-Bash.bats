bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
  # Sandbox session dir so approval state stays isolated per test
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

# --- Integration tests (real Solkan) ---

@test "integration: allow echo hello with no rewrite" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "integration: passes grep count through unchanged" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"grep -c x f"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'grep -c x f'
}

@test "integration: passes cat through unchanged" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"cat hooks/stop"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'cat hooks/stop'
}

@test "integration: rewrites ls to the token-saving variant" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"ls -la dir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'ls-token-saving -la dir'
}

@test "integration: passes git status through unchanged" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'git status'
}

@test "integration: applies rm guard-rail on a single command" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm -f a"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rm-guarded -f a'
}

@test "integration: applies rm guard-rail inside a compound command" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm -f a && ls | wc -l"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rm-guarded -f a && ls | wc -l'
}

@test "integration: rewrite rmdir to rmdir-guarded" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rmdir emptydir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rmdir-guarded emptydir'
}

@test "integration: rewrite google-login to google-login-guarded" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"google-login"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'google-login-guarded'
}

@test "integration: rewrite google-login and keep its flag" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"google-login --perso"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'google-login-guarded --perso'
}

@test "integration: rewrite google-login inside a pipe or a conditional" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"google-login --perso | cat && google-login || echo failed"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'google-login-guarded --perso | cat && google-login-guarded || echo failed'
}

@test "integration: reject wget with reason" {
  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "integration: a binary in the session allow-list is auto-approved" {
  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; sessionAllowListAdd --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
}

@test "integration: reason only mentions binaries missing from the session allow-list" {
  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; sessionAllowListAdd --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com && telnet bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ telnet ❌'
}

# --- Mocked tests ---

@test "allow with updatedInput when solkan allows and does not rewrite" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "ask permissionDecision with updatedInput when solkan refuses" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget evil.com'
}

@test "permissionDecisionReason lists rejected commands when solkan refuses" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
}

@test "no systemMessage when solkan rejects" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json_null '.hookSpecificOutput.systemMessage'
}

@test "hook logs to CLAUDE_HOOKS_LOG_DIR" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/last-bash-input.json" ]]
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

@test "repeat reject in session: ask with reason every time" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget")
    return 1
  }
  bats_mock solkanEvaluate

  local input='{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
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

@test "reject without session_id: ask with reason" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "reject records an approval pending entry with the tool use id and all rejected commands" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget" "curl")
    return 1
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"echo ok; wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'

  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; approvalPendingGet --tool-use-id toolu_01"
  [[ "$output" = $'wget\ncurl' ]]
}

@test "reject shows a half moon next to a binary approved once" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("wget")
    return 1
  }
  bats_mock solkanEvaluate

  local sourcePrefix="CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget 🌓 ❌'
}

@test "reject shows each binary with the moon of its own approval count" {
  solkanEvaluate() {
    SOLKAN_VERDICT=reject
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=("/usr/bin/grep" "wget")
    return 1
  }
  bats_mock solkanEvaluate

  local sourcePrefix="CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"/usr/bin/grep x | wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ /usr/bin/grep 🌕, wget ❌'
}

@test "allow records no approval pending entry" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  [[ ! -e "$BATS_TMP_DIR/test/state.json" ]]
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

@test "no CLAUDE_IS_SUBAGENT prefix when agent_id absent" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "rm rewritten: allow with rewrittenCommand as updatedInput" {
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

@test "rmdir rewritten: allow with rewrittenCommand as updatedInput" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND='rmdir-guarded emptydir'
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rmdir emptydir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rmdir-guarded emptydir'
}

@test "compound rm rewritten: allow with rewrittenCommand as updatedInput" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND='ls && rm-guarded foo.txt'
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"ls && rm foo.txt"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'ls && rm-guarded foo.txt'
}

@test "no rewrittenCommand from solkan: uses original inputCommand" {
  solkanEvaluate() {
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "passes the cwd of the input JSON to solkanEvaluate" {
  solkanEvaluate() {
    print -r -- "$2" > "$BATS_TMP_DIR/solkan-cwd.txt"
    SOLKAN_VERDICT=allow
    SOLKAN_COMMAND="$1"
    SOLKAN_REJECTED=()
  }
  bats_mock solkanEvaluate

  bats_run_zsh "$SCRIPT" <<<'{"cwd":"/some/worktree","tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/solkan-cwd.txt")" == "/some/worktree" ]]
}
