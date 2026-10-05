bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_mock_env "OROSHI_CONFLUENCE_EMAIL" "me@example.com"
  bats_mock_env "OROSHI_CONFLUENCE_API_TOKEN" "secret-token"
  bats_mock_env "OROSHI_CONFLUENCE_CLOUD_ID" "cloud-123"
}

# Stub curl to return a body followed by the HTTP status on its own line
stub_curl() {
  echo "$1" >"$BATS_TMP_DIR/body.json"
  bats_mock_env "STUB_HTTP_BODY" "$BATS_TMP_DIR/body.json"
  bats_mock_env "STUB_HTTP_STATUS" "$2"
  curl() {
    cat "$STUB_HTTP_BODY"
    printf "\n%s" "$STUB_HTTP_STATUS"
  }
  bats_mock curl
}

@test "names the missing variable when the token is not set" {
  # An empty value counts as missing; unset would be undone by the mock trap
  bats_mock_env "OROSHI_CONFLUENCE_API_TOKEN" ""
  stub_curl '{}' 200

  bats_run_zsh "confluence-api wiki/api/v2/pages/1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"OROSHI_CONFLUENCE_API_TOKEN"* ]]
}

@test "returns the response body on success" {
  stub_curl '{"id":"1"}' 200

  bats_run_zsh "confluence-api wiki/api/v2/pages/1"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '{"id":"1"}' ]]
}

@test "reports an expired or wrong token on 401" {
  stub_curl '{"message":"Unauthorized"}' 401

  bats_run_zsh "confluence-api wiki/api/v2/pages/1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"401"* ]]
  [[ "$output" == *"token"* ]]
}

@test "reports an unknown or restricted page on 404" {
  stub_curl '{"message":"Not Found"}' 404

  bats_run_zsh "confluence-api wiki/api/v2/pages/1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"404"* ]]
  [[ "$output" == *"not found or restricted"* ]]
}

@test "reports the status on any other non-2xx" {
  stub_curl '{"message":"Boom"}' 500

  bats_run_zsh "confluence-api wiki/api/v2/pages/1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"500"* ]]
}
