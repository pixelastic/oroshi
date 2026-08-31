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
    printf '{"content":[{"type":"text","text":"Hello from Claude"}]}▮200'
  }
BASH
}

# Mock curl to return an HTTP error response
_mock_curl_http_error() {
  cat <<'BASH'
  curl() {
    echo "$@" > "$BATS_TMP_DIR/curl.log"
    printf '{"type":"error","error":{"type":"authentication_error","message":"Invalid API key"}}▮401'
  }
BASH
}

# Mock curl to return an empty response body
_mock_curl_empty() {
  cat <<'BASH'
  curl() {
    echo "$@" > "$BATS_TMP_DIR/curl.log"
    printf '▮200'
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

@test "reads user content from stdin when no positional argument given" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api" <<<"hello from stdin"
  [[ "$status" -eq 0 ]]
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"hello from stdin"* ]]
}

@test "prefers positional argument over stdin when both are available" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'positional content'" <<<"stdin content"
  [[ "$status" -eq 0 ]]
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"positional content"* ]]
  [[ "$args" != *"stdin content"* ]]
}

@test "includes system field in API body when --system is passed" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api --system 'Be helpful' 'hello'"
  [[ "$status" -eq 0 ]]
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" == *"system"* ]]
  [[ "$args" == *"Be helpful"* ]]
}

@test "omits system field from API body when --system is not passed" {
  eval "$(_mock_curl)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  local args=$(cat "$BATS_TMP_DIR/curl.log")
  [[ "$args" != *'"system"'* ]]
}

@test "returns exit code 1 and prints to stderr on HTTP error" {
  eval "$(_mock_curl_http_error)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]
}

@test "returns exit code 1 and prints to stderr on empty response" {
  eval "$(_mock_curl_empty)"
  bats_mock curl

  bats_run_zsh "claude-api 'hello'"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Empty"* ]]
}
