bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
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

@test "ask shows single rejected command" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
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

@test "first encounter: ask with reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget ❌'
}

@test "repeat encounter: defer with no reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'defer'
  expect_json_null '.hookSpecificOutput.permissionDecisionReason'
}

@test "multi-reject all new: ask with all rejected in reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ wget, curl ❌'
}

@test "multi-reject all seen: defer with no reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget","curl"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'defer'
  expect_json_null '.hookSpecificOutput.permissionDecisionReason'
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

@test "multi-reject mixed: ask with only new rejected in reason" {
  preToolUse-Bash-solkan() {
    print '{"allow":{"isAllowed":false,"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  rtk-command-rewrite() { print -r -- "$1"; }
  bats_mock preToolUse-Bash-solkan rtk-command-rewrite

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' '❌ curl ❌'
}
