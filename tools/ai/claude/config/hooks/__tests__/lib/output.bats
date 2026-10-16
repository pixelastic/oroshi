bats_load_library 'helper'

setup() {
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../../lib/output.zsh'"
}

# autoApprove

@test "autoApprove prints the allow decision with the command in updatedInput" {
  bats_run_zsh "${sourcePrefix}; autoApprove 'echo hello'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'allow'
  expect_json '.hookSpecificOutput.updatedInput.command' 'echo hello'
}

# askWithReason

@test "askWithReason prints the ask decision with the reason and the command in updatedInput" {
  bats_run_zsh "${sourcePrefix}; askWithReason 'not allowed' 'wget foo'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PreToolUse'
  expect_json '.hookSpecificOutput.permissionDecision' 'ask'
  expect_json '.hookSpecificOutput.permissionDecisionReason' 'not allowed'
  expect_json '.hookSpecificOutput.updatedInput.command' 'wget foo'
}

# askReasonFormat

@test "askReasonFormat shows a command with count 0 without symbol" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 0"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget ❌" ]]
}

@test "askReasonFormat shows a command with count 1 with a half moon" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌓 ❌" ]]
}

@test "askReasonFormat shows a command with count 2 with a full moon" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 2"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌕 ❌" ]]
}

@test "askReasonFormat shows a command with count 3 with a full moon" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command wget --count 3"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ wget 🌕 ❌" ]]
}

@test "askReasonFormat joins several commands with a comma, each with its own symbol" {
  bats_run_zsh "${sourcePrefix}; askReasonFormat --command /usr/bin/grep --count 2 --command wget --count 0 --command curl --count 1"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "❌ /usr/bin/grep 🌕, wget, curl 🌓 ❌" ]]
}

# additionalContext

@test "additionalContext prints the PostToolUse event name and the context text" {
  bats_run_zsh "${sourcePrefix}; additionalContext PostToolUse 'remember this'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PostToolUse'
  expect_json '.hookSpecificOutput.additionalContext' 'remember this'
}

@test "additionalContext prints the PostToolUseFailure event name" {
  bats_run_zsh "${sourcePrefix}; additionalContext PostToolUseFailure 'it failed'"
  [[ "$status" -eq 0 ]]
  expect_json '.hookSpecificOutput.hookEventName' 'PostToolUseFailure'
  expect_json '.hookSpecificOutput.additionalContext' 'it failed'
}
