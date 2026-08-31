bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_ANTHROPIC_API_KEY" "test-key-abc"
}

# Mock curl to return a valid Claude API response and log all args
_mock_curl() {
  cat <<'BASH'
  curl() {
    echo "$@" > "$BATS_TMP_DIR/curl.log"
    printf '{"content":[{"type":"text","text":"Hello from Claude"}]}'
  }
BASH
}

@test "outputs response text to stdout" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'What is 2+2?'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Hello from Claude" ]]
}

@test "sends prompt as user message content" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'Tell me a joke'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"Tell me a joke"* ]]
}

@test "uses default model claude-sonnet-4-6 when no --model flag" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"claude-sonnet-4-6"* ]]
}

@test "uses default max_tokens 4096 when no --max-tokens flag" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"4096"* ]]
}

@test "resolves model alias opus to full ID" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api --model opus 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"claude-opus-4-6"* ]]
}

@test "resolves model alias haiku to full ID" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api --model haiku 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"claude-haiku-4-5-20251001"* ]]
}

@test "uses specified max_tokens when --max-tokens is passed" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api --max-tokens 1024 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"1024"* ]]
}

@test "uses specified model when --model is passed with full ID" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api --model claude-sonnet-4-6 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"claude-sonnet-4-6"* ]]
}

@test "returns exit code 1 when OROSHI_ANTHROPIC_API_KEY is empty" {
  bats_mock_env "OROSHI_ANTHROPIC_API_KEY" ""

  bats_run_zsh "claude-api 'hello'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"OROSHI_ANTHROPIC_API_KEY"* ]]
}

@test "sends OROSHI_ANTHROPIC_API_KEY in x-api-key header" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"x-api-key: test-key-abc"* ]]
}
