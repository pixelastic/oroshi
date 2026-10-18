# Guarded helpers: spot the refusals of a guarded command, and tell Claude about them
# A guarded command (e.g. rm-guarded) that refuses to act writes a refusal line in its output
# A refusal line starts with the refusal prefix, then the message for Claude
# Needs lib/input.zsh sourced and hookInit called first (CLAUDE_HOOK_INPUT is the post event JSON)
# Usage:
# $ source lib/guarded.zsh
# $ local refusalMessages="$(guardedRefusalRead)"
# $ [[ "$refusalMessages" != "" ]] && guardedRefusalReport "$refusalMessages"

# Written at the start of a refusal line by the guarded helpers
GUARDED_REFUSAL_PREFIX='[claude-guarded:refused]'

# Print the output of the command, whatever the event
# Failure event: output lives in .error. Success event: in .tool_response
# Collect every field present, skip the missing ones, one line per field
# Usage:
# $ guardedOutputRead
function guardedOutputRead() {
  local outputFilter='
    [.error, .tool_response.stdout, .tool_response.stderr]
    | map(strings)
    | join("\n")
  '
  jq --raw-output "$outputFilter" <<<"$CLAUDE_HOOK_INPUT"
}

# Print the refusal lines of the command output, one per line, without the refusal prefix
# Prints nothing when the command was not refused
# Usage:
# $ guardedRefusalRead
function guardedRefusalRead() {
  local line
  for line in ${(f)"$(guardedOutputRead)"}; do
    # Not a refusal line: skip it
    [[ "$line" != "$GUARDED_REFUSAL_PREFIX"* ]] && continue

    # Drop the prefix, then the space that follows it
    print -r -- "${${line#"$GUARDED_REFUSAL_PREFIX"}# }"
  done
}

# Tell Claude about the refusals: print the messages as the additionalContext of the hook event
# Does not end the hook
# Usage:
# $ guardedRefusalReport "$(guardedRefusalRead)"
function guardedRefusalReport() {
  local eventName="$(inputKeyRead '.hook_event_name')"
  local contextText="$1"

  jo -d. \
    hookSpecificOutput.hookEventName="$eventName" \
    hookSpecificOutput.additionalContext="$contextText"
}
