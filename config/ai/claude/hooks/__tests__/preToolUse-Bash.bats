setup() {
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash"

  printf '#!/usr/bin/env zsh\nexit 0\n' > "$BATS_TEST_TMPDIR/mock-solkan-allow"
  printf '#!/usr/bin/env zsh\nexit 1\n' > "$BATS_TEST_TMPDIR/mock-solkan-ask"
  printf '#!/usr/bin/env zsh\nprint -- "$1"\n' > "$BATS_TEST_TMPDIR/mock-rtk-pass"
  printf '#!/usr/bin/env zsh\nprint -- "rtk $1"\n' > "$BATS_TEST_TMPDIR/mock-rtk-rewrite"
  chmod +x "$BATS_TEST_TMPDIR"/mock-*
}

_run_hook() {
  local solkan="$1" rtk="$2" json="$3"
  printf '%s' "$json" > "$BATS_TEST_TMPDIR/input.json"
  run env \
    PRETOOLUSE_SOLKAN_SCRIPT="$solkan" \
    PRETOOLUSE_RTK_SCRIPT="$rtk" \
    "$SCRIPT" < "$BATS_TEST_TMPDIR/input.json"
}

@test "allow with no updatedInput when solkan allows and RTK does not rewrite" {
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-allow" \
    "$BATS_TEST_TMPDIR/mock-rtk-pass" \
    '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq '.hookSpecificOutput | has("updatedInput")')" = "false" ]
}

@test "allow with updatedInput.command when solkan allows and RTK rewrites" {
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-allow" \
    "$BATS_TEST_TMPDIR/mock-rtk-rewrite" \
    '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "no permissionDecision and no updatedInput when solkan refuses and RTK does not rewrite" {
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-ask" \
    "$BATS_TEST_TMPDIR/mock-rtk-pass" \
    '{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.hookSpecificOutput | has("permissionDecision")')" = "false" ]
  [ "$(echo "$output" | jq '.hookSpecificOutput | has("updatedInput")')" = "false" ]
}

@test "updatedInput.command but no permissionDecision when solkan refuses and RTK rewrites" {
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-ask" \
    "$BATS_TEST_TMPDIR/mock-rtk-rewrite" \
    '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.hookSpecificOutput | has("permissionDecision")')" = "false" ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "rtk git status" ]
}

@test "preserves original tool_input fields in updatedInput when rewriting" {
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-allow" \
    "$BATS_TEST_TMPDIR/mock-rtk-rewrite" \
    '{"tool_name":"Bash","tool_input":{"command":"git status","description":"Show repo status"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.updatedInput.description')" = "Show repo status" ]
}

@test "no background jobs in script" {
  run grep -E '[^&]&[[:space:]]*$' "$SCRIPT"
  [ "$status" -ne 0 ]
}

@test "solkan completes before RTK starts" {
  local log="$BATS_TEST_TMPDIR/order.log"
  printf '#!/usr/bin/env zsh\nsleep 0.05\nprint SOLKAN >> %s\n' "$log" > "$BATS_TEST_TMPDIR/mock-solkan-order"
  printf '#!/usr/bin/env zsh\nprint RTK >> %s\nprint -- "$1"\n' "$log" > "$BATS_TEST_TMPDIR/mock-rtk-order"
  chmod +x "$BATS_TEST_TMPDIR/mock-solkan-order" "$BATS_TEST_TMPDIR/mock-rtk-order"
  _run_hook \
    "$BATS_TEST_TMPDIR/mock-solkan-order" \
    "$BATS_TEST_TMPDIR/mock-rtk-order" \
    '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
  [ "$status" -eq 0 ]
  [ "$(head -1 "$log")" = "SOLKAN" ]
}
