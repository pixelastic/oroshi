bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/input.zsh'; source '${BATS_TEST_DIRNAME}/../../lib/guarded.zsh'"
}

# Hook JSON of a failed command: its output lives in .error
failureInput() {
  jo hook_event_name=PostToolUseFailure error="$1"
}

# Hook JSON of a successful command: its output lives in .tool_response
successInput() {
  local response="$(jo stdout="$1" stderr="$2")"
  jo hook_event_name=PostToolUse tool_response="$response"
}

# guardedRefusalRead

@test "guardedRefusalRead prints the refusal line without its prefix" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput $'Exit code 1\n[claude-guarded:refused] Retry with /bin/rm.')"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "Retry with /bin/rm." ]]
}

@test "guardedRefusalRead prints one line per refusal line" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput $'[claude-guarded:refused] First.\n[claude-guarded:refused] Second.')"
  [[ "$output" = $'First.\nSecond.' ]]
}

@test "guardedRefusalRead accepts a refusal line without a space after the prefix" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput '[claude-guarded:refused]Retry.')"
  [[ "$output" = "Retry." ]]
}

@test "guardedRefusalRead drops the lines that are not refusal lines" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput $'Exit code 1\nsome stdout\n[claude-guarded:refused] Retry.\nrm: other failure')"
  [[ "$output" = "Retry." ]]
}

@test "guardedRefusalRead prints nothing when the command was not refused" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput $'Exit code 1\nrm: No such file')"
  [[ "$output" = "" ]]
}

@test "guardedRefusalRead ignores a prefix that is not at the start of the line" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(failureInput 'echo [claude-guarded:refused] Retry.')"
  [[ "$output" = "" ]]
}

@test "guardedRefusalRead reads stdout and stderr of a successful command" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalRead" <<<"$(successInput $'[claude-guarded:refused] Out.' '[claude-guarded:refused] Err.')"
  [[ "$output" = $'Out.\nErr.' ]]
}

# guardedRefusalReport

@test "guardedRefusalReport prints the given messages as additionalContext of the event" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalReport \$'First.\nSecond.'" <<<"$(failureInput 'Exit code 1')"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.additionalContext' <<<"$output")" = $'First.\nSecond.' ]]
  [[ "$(jq --raw-output '.hookSpecificOutput.hookEventName' <<<"$output")" = "PostToolUseFailure" ]]
}

@test "guardedRefusalReport does not end the calling shell" {
  bats_run_zsh "${sourcePrefix}; hookInit; guardedRefusalReport Retry. >/dev/null; print after" <<<"$(failureInput 'Exit code 1')"
  [[ "$output" = "after" ]]
}
