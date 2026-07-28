# shellcheck disable=SC2089,SC2090
bats_load_library 'helper'

# --- expect_json ---

@test "expect_json passes when jq path value matches expected string" {
  output='{"name":"alice"}'
  expect_json '.name' 'alice'
}

@test "expect_json fails when jq path value differs from expected string" {
  output='{"name":"alice"}'
  run expect_json '.name' 'bob'
  [[ "$status" -ne 0 ]]
}

@test "expect_json failure message contains function name, jq path, expected value, and actual value" {
  output='{"name":"alice"}'
  run expect_json '.name' 'bob'
  [[ "$output" == "expect_json .name: expected 'bob', got 'alice'" ]]
}

# --- expect_json_null ---

@test "expect_json_null passes when jq path value is null" {
  output='{"name":null}'
  expect_json_null '.name'
}

@test "expect_json_null fails when jq path value is not null" {
  output='{"name":"alice"}'
  run expect_json_null '.name'
  [[ "$status" -ne 0 ]]
}

# --- expect_json_glob ---

@test "expect_json_glob passes when jq path value matches glob pattern" {
  output='{"path":"/home/alice/docs"}'
  expect_json_glob '.path' '/home/*/docs'
}

@test "expect_json_glob fails when jq path value does not match glob pattern" {
  output='{"path":"/home/alice/docs"}'
  run expect_json_glob '.path' '/var/*'
  [[ "$status" -ne 0 ]]
}

# --- integration ---

@test "helpers are available after bats_load_library helper without extra import" {
  output='{"ok":true}'
  expect_json '.ok' 'true'
}
