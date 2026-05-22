DISPATCHER="$(dirname "$BATS_TEST_FILENAME")/../preToolUse"
SETTINGS="$HOME/.claude/settings.json"
RTK_HOOK="$HOME/.claude/hooks/rtk-rewrite.sh"

@test "settings.json: Bash matcher points to preToolUse-Bash" {
  run jq -r '.hooks.PreToolUse[] | select(.matcher == "Bash") | .hooks[0].command' "$SETTINGS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"preToolUse-Bash"* ]]
}

@test "settings.json: no rtk-rewrite.sh entry" {
  run grep "rtk-rewrite" "$SETTINGS"
  [ "$status" -ne 0 ]
}

@test "rtk-rewrite.sh is deleted" {
  [ ! -f "$RTK_HOOK" ]
}

@test "dispatcher: Bash guard appears before generic handler" {
  # Bash early-return must precede the generic specificToolHandler block
  local guardLine="$(grep -n 'toolName.*Bash\|Bash.*toolName' "$DISPATCHER" | head -1 | cut -d: -f1)"
  local handlerLine="$(grep -n 'specificToolHandler' "$DISPATCHER" | head -1 | cut -d: -f1)"
  [ -n "$guardLine" ]
  [ -n "$handlerLine" ]
  [ "$guardLine" -lt "$handlerLine" ]
}
