bats_load_library 'helper'

setup() {
  bats_tmp_dir
  SCRIPT="$BATS_TEST_DIRNAME/../preToolUse-Write"
}

@test "allow Write to /tmp/oroshi/claude/ subpath" {
  local input='{"tool_name":"Write","tool_input":{"file_path":"/tmp/oroshi/claude/slack-writer/abc.md"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
}

@test "allow Write inside a plans/ directory" {
  local input='{"tool_name":"Write","tool_input":{"file_path":"/home/tim/local/www/plans/repo--feat-foo/PRD.md"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
}

@test "no decision for path outside allowlist" {
  local input='{"tool_name":"Write","tool_input":{"file_path":"/home/tim/project/src/index.js"}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "no decision when file_path is empty" {
  local input='{"tool_name":"Write","tool_input":{"file_path":""}}'
  bats_run_zsh "$SCRIPT" <<<"$input"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
