bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
  # Sandbox session dir so approval state stays isolated per test
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

# --- Integration tests (real Solkan, mocked RTK) ---

@test "integration: allow echo hello with no rewrite" {
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "integration: rewrite rmdir to rmdir-for-claude" {
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rmdir emptydir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rmdir-for-claude emptydir'
}

@test "integration: reject wget with reason" {
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "integration: a binary in the session allow-list is auto-approved" {
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock rtk-command-rewrite

  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; sessionAllowListAdd --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
}

@test "integration: reason only mentions binaries missing from the session allow-list" {
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock rtk-command-rewrite

  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; sessionAllowListAdd --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com && telnet bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ telnet ❌'
}

# --- Mocked tests ---

@test "allow with updatedInput when solkan allows and RTK does not rewrite" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "allow with updatedInput.command when solkan allows and RTK rewrites" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["git"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "rtk $1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rtk git status'
}

@test "ask permissionDecision with updatedInput when solkan refuses and RTK does not rewrite" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget evil.com'
}

@test "ask permissionDecision with updatedInput.command when solkan refuses and RTK rewrites" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "rtk $1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rtk git status'
}

@test "permissionDecisionReason lists rejected commands when solkan refuses" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
}

@test "no systemMessage when solkan rejects" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json_null '.hookSpecificOutput.systemMessage'
}

@test "hook logs to CLAUDE_HOOKS_LOG_DIR" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/last-bash-input.json" ]]
}

@test "preserves \xa0 as literal chars through full hook pipeline" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo \\xa0"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo \xa0'
}

@test "no background jobs in script" {
  run grep -E '[^&]&[[:space:]]*$' "$SCRIPT"
  [[ "$status" -ne 0 ]]
}

@test "solkan completes before RTK starts" {
  preToolUse-Bash-solkan() {
    sleep 0.05
    print SOLKAN >>"$BATS_TMP_DIR/order.log"
    print '{"allow":{"isAllowed":true}}'
  }
  rtk-command-rewrite() {
    print RTK >>"$BATS_TMP_DIR/order.log"
    print -r -- "$1"
  }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  [[ "$(head -1 "$BATS_TMP_DIR/order.log")" = "SOLKAN" ]]
}

@test "repeat reject in session: ask with reason every time" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  local input='{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "repeat multi-reject in session: ask listing all rejected every time" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  local input='{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
}

@test "reject without session_id: ask with reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "reject records an approval pending entry with the tool use id and all rejected commands" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":["echo"],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"echo ok; wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'

  bats_run_zsh "CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'; approvalPendingGet --tool-use-id toolu_01"
  [[ "$output" = $'wget\ncurl' ]]
}

@test "reject shows a half moon next to a binary approved once" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  local sourcePrefix="CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command wget"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget 🌓 ❌'
}

@test "reject shows each binary with the moon of its own approval count" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["/usr/bin/grep","wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  local sourcePrefix="CLAUDE_SESSION_ID=test; source '$BATS_TEST_DIRNAME/../Bash-approval.zsh'"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"
  bats_run_zsh "${sourcePrefix}; approvalCountIncrement --command /usr/bin/grep"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"/usr/bin/grep x | wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ /usr/bin/grep 🌕, wget ❌'
}

@test "allow records no approval pending entry" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_use_id":"toolu_01","tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  [[ ! -e "$BATS_TMP_DIR/test/state.json" ]]
}

@test "prefixes command with CLAUDE_IS_SUBAGENT export when agent_id present" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"},"agent_id":"sub-123"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'export CLAUDE_IS_SUBAGENT=1; echo hello'
}

@test "prefixes command with CLAUDE_IS_SUBAGENT export on rejected path" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"},"agent_id":"sub-123"}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'export CLAUDE_IS_SUBAGENT=1; wget evil.com'
}

@test "no CLAUDE_IS_SUBAGENT prefix when agent_id absent" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "rm rewritten: allow with rewrittenCommand as updatedInput" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["rm-for-claude"],"rejected":[]},"rewrite":"rm-for-claude foo.txt"}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm foo.txt"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rm-for-claude foo.txt'
}

@test "rmdir rewritten: allow with rewrittenCommand as updatedInput" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["rmdir-for-claude"],"rejected":[]},"rewrite":"rmdir-for-claude emptydir"}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rmdir emptydir"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rmdir-for-claude emptydir'
}

@test "compound rm rewritten: allow with rewrittenCommand as updatedInput" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["ls","rm-for-claude"],"rejected":[]},"rewrite":"ls && rm-for-claude foo.txt"}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"ls && rm foo.txt"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'ls && rm-for-claude foo.txt'
}

@test "no rewrittenCommand from solkan: uses original inputCommand" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["echo"],"rejected":[]}}'
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

@test "rewrite + RTK: both transformations applied" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":true,"allowed":["rm-for-claude"],"rejected":[]},"rewrite":"rm-for-claude foo.txt"}'
  }
  rtk-command-rewrite() { print -r -- "rtk $1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"rm foo.txt"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'rtk rm-for-claude foo.txt'
}
