bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export TRANSCRIPT="$BATS_TMP_DIR/transcript.jsonl"
}

# Write a deferred_tools_delta transcript entry adding the given tool names
add_tools() {
  local names="$(jo -a "$@")"
  jo type=attachment attachment="$(jo type=deferred_tools_delta addedNames="$names" removedNames="$(jo -a)")" >>"$TRANSCRIPT"
}

# Write a deferred_tools_delta transcript entry removing the given tool names
remove_tools() {
  local names="$(jo -a "$@")"
  jo type=attachment attachment="$(jo type=deferred_tools_delta addedNames="$(jo -a)" removedNames="$names")" >>"$TRANSCRIPT"
}

@test "lists a server that has a real tool" {
  add_tools mcp__claude_ai_Slack__slack_read_channel

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "claude_ai_Slack" ]]
}

@test "hides a server that has only authentication tools" {
  add_tools mcp__claude_ai_Gmail__authenticate mcp__claude_ai_Gmail__complete_authentication

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "lists a server that has authentication tools next to a real tool" {
  add_tools mcp__context7__authenticate mcp__context7__query-docs

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "context7" ]]
}

@test "lists each server once, one per line, in order of appearance" {
  add_tools mcp__claude_ai_Slack__slack_read_channel mcp__context7__query-docs
  add_tools mcp__claude_ai_Slack__slack_read_thread

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == $'claude_ai_Slack\ncontext7' ]]
}

@test "ignores tools that do not belong to an MCP server" {
  add_tools Bash Read

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "" ]]
}

@test "ignores transcript lines that are not deferred_tools_delta entries" {
  echo '{"type":"user","message":"mcp__claude_ai_Slack__slack_read_channel"}' >"$TRANSCRIPT"

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "" ]]
}

@test "prints nothing for an empty transcript" {
  : >"$TRANSCRIPT"

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "prints nothing when the transcript is missing" {
  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "lists a server added in a later entry" {
  add_tools mcp__claude_ai_Slack__slack_read_channel
  add_tools mcp__context7__query-docs

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == $'claude_ai_Slack\ncontext7' ]]
}

@test "hides a server whose tools are all removed" {
  add_tools mcp__claude_ai_Slack__slack_read_channel mcp__context7__query-docs
  remove_tools mcp__claude_ai_Slack__slack_read_channel

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "context7" ]]
}

@test "keeps a server that still has a tool after a partial removal" {
  add_tools mcp__claude_ai_Slack__slack_read_channel mcp__claude_ai_Slack__slack_read_thread
  remove_tools mcp__claude_ai_Slack__slack_read_channel

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "claude_ai_Slack" ]]
}

@test "lists a server that was removed then added again" {
  add_tools mcp__claude_ai_Slack__slack_read_channel
  remove_tools mcp__claude_ai_Slack__slack_read_channel
  add_tools mcp__claude_ai_Slack__slack_read_channel

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "claude_ai_Slack" ]]
}

@test "lists a server that swaps authentication tools for real tools" {
  add_tools mcp__claude_ai_Gmail__authenticate mcp__claude_ai_Gmail__complete_authentication
  remove_tools mcp__claude_ai_Gmail__authenticate mcp__claude_ai_Gmail__complete_authentication
  add_tools mcp__claude_ai_Gmail__search_threads

  bats_run_zsh "claude-transcript-mcp-list-raw $TRANSCRIPT"
  [[ "$output" == "claude_ai_Gmail" ]]
}
