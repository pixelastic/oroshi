bats_load_library 'helper'

setup() {
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/permission.zsh'"
}

# autoApprove

@test "autoApprove prints the allow decision with the whole tool input in updatedInput" {
  bats_run_zsh "${sourcePrefix}; autoApprove '{\"command\":\"echo hello\",\"description\":\"Say hi\",\"timeout\":5000}'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Say hi'
  expect_json '.hookSpecificOutput.updatedInput.timeout' '5000'
}

@test "autoApprove prints the allow decision without updatedInput when no tool input is given" {
  bats_run_zsh "${sourcePrefix}; autoApprove"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput' 'null'
}

# askWithReason

@test "askWithReason prints the ask decision with the reason and the whole tool input in updatedInput" {
  bats_run_zsh "${sourcePrefix}; askWithReason 'not allowed' '{\"command\":\"wget foo\",\"description\":\"Fetch\",\"timeout\":5000}'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' 'not allowed'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget foo'
  expect_json '.hookSpecificOutput.updatedInput.description' 'Fetch'
  expect_json '.hookSpecificOutput.updatedInput.timeout' '5000'
}

# rejectedCommandsFormat

@test "rejectedCommandsFormat shows a command with count 0 without symbol" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat wget:0"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget ❌" ]]
}

@test "rejectedCommandsFormat shows a command with count 1 with a half moon" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat wget:1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌓 ❌" ]]
}

@test "rejectedCommandsFormat shows a command with count 2 with a full moon" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat wget:2"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌕 ❌" ]]
}

@test "rejectedCommandsFormat shows a command with count 3 with a full moon" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat wget:3"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌕 ❌" ]]
}

@test "rejectedCommandsFormat joins several commands with a comma, each with its own symbol" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat /usr/bin/grep:2 wget:0 curl:1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ /usr/bin/grep 🌕, wget, curl 🌓 ❌" ]]
}

@test "rejectedCommandsFormat splits on the last colon" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat a:b:1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ a:b 🌓 ❌" ]]
}

@test "rejectedCommandsFormat treats a missing count as 0" {
  bats_run_zsh "${sourcePrefix}; rejectedCommandsFormat wget"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget ❌" ]]
}
